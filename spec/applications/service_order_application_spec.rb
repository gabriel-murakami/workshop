require 'rails_helper'

RSpec.describe Application::ServiceOrder::ServiceOrderApplication do
  let(:service_order_repository) { Infra::Repositories::ServiceOrderRepository.new }
  let(:application) { described_class.new(service_order: service_order_repository) }

  describe "#find_all" do
    it "returns filtered service orders" do
      so1 = create(:service_order, status: "received")
      so2 = create(:service_order, status: "cancelled")
      result = application.find_all

      expect(result.map(&:id)).to include(so1.id)
      expect(result.map(&:id)).not_to include(so2.id)
    end
  end

  describe "#find_by_id" do
    it "finds a service order by id" do
      service_order = create(:service_order)
      expect(application.find_by_id(service_order.id)).to eq(service_order)
    end
  end

  describe "#send_to_diagnosis" do
    it "updates the status to diagnosis" do
      service_order = create(:service_order, status: "received")
      command = Application::ServiceOrder::Commands::SendToDiagnosisCommand.new(service_order_id: service_order.id)
      updated = application.send_to_diagnosis(command)
      expect(updated.status).to eq("diagnosis")
    end
  end

  describe "#send_to_approval" do
    it "updates status to waiting_approval and creates a budget" do
      service_order = create(:service_order, status: "diagnosis")
      command = Application::ServiceOrder::Commands::SendToApprovalCommand.new(service_order_id: service_order.id)
      expect_any_instance_of(Application::ServiceOrder::BudgetApplication).to receive(:create_budget)
      updated = application.send_to_approval(command)
      expect(updated.status).to eq("waiting_approval")
    end
  end

  describe "#add_services" do
    it "adds services to the service order" do
      service_order = create(:service_order, status: 'diagnosis')
      service1 = create(:service, code: "SVC001")
      service2 = create(:service, code: "SVC002")
      command = Application::ServiceOrder::Commands::AddServicesCommand.new(
        service_order_id: service_order.id,
        services_codes: [ service1.code, service2.code ]
      )

      application.add_services(command)

      service_order.reload
      codes = service_order.service_order_items.map { |item| item.item.code }
      expect(codes).to include("SVC001", "SVC002")
    end
  end

  describe "#add_products" do
    it "adds products to the service order and removes stock" do
      service_order = create(:service_order, status: 'diagnosis')
      product1 = create(:product, sku: "AP001", stock_quantity: 10)
      product2 = create(:product, sku: "AP002", stock_quantity: 5)

      products_params = [ { sku: product1.sku, quantity: 2 }, { sku: product2.sku, quantity: 1 } ]

      command = Application::ServiceOrder::Commands::AddProductsCommand.new(
        service_order_id: service_order.id,
        products_params: products_params
      )

      application.add_products(command)

      service_order.reload
      skus = service_order.service_order_items.map { |item| item.item.sku }

      expect(skus).to include("AP001", "AP002")
      expect(product1.reload.stock_quantity).to eq(8)
      expect(product2.reload.stock_quantity).to eq(4)
    end
  end

  describe "#approve_service_order" do
    it "updates status to approved" do
      service_order = create(:service_order, status: "waiting_approval")
      command = Application::ServiceOrder::Commands::ApproveServiceOrderCommand.new(service_order_id: service_order.id)

      application.approve_service_order(command)

      expect(service_order.reload.status).to eq("approved")
    end
  end

  describe "#cancel_service_order" do
    it "updates status to cancelled and replaces products stock" do
      service_order = create(:service_order, status: "waiting_approval")
      product = create(:product, stock_quantity: 5)

      create(:service_order_item, service_order: service_order, quantity: 2, item: product)
      command = Application::ServiceOrder::Commands::CancelServiceOrderCommand.new(service_order_id: service_order.id)

      application.cancel_service_order(command)

      expect(service_order.reload.status).to eq("cancelled")
      expect(product.reload.stock_quantity).to eq(7)
    end
  end

  describe "#start_service_order" do
    it "starts the service order setting status and start time" do
      service_order = create(:service_order, status: "approved")
      command = Application::ServiceOrder::Commands::StartServiceOrderCommand.new(service_order_id: service_order.id)

      updated = application.start_service_order(command)
      expect(updated.status).to eq("in_progress")
      expect(updated.service_started_at).not_to be_nil
    end

    it "raises error if already started" do
      service_order = create(:service_order, status: "in_progress")
      command = Application::ServiceOrder::Commands::StartServiceOrderCommand.new(service_order_id: service_order.id)

      expect {
        application.start_service_order(command)
      }.to raise_error(Exceptions::ServiceOrderException, "Service order already started")
    end
  end

  describe "#finish_service_order" do
    it "finishes the service order setting status and finish time and updates metric" do
      service_order = create(:service_order, status: "in_progress", service_started_at: 1.hour.ago)
      command = Application::ServiceOrder::Commands::FinishServiceOrderCommand.new(service_order_id: service_order.id)

      expect_any_instance_of(Application::ServiceOrder::MetricApplication).to receive(:update_metric)
      updated = application.finish_service_order(command)
      expect(updated.status).to eq("finished")
      expect(updated.service_finished_at).not_to be_nil
    end

    it "raises error if already finished" do
      service_order = create(:service_order, status: "finished")
      command = Application::ServiceOrder::Commands::FinishServiceOrderCommand.new(service_order_id: service_order.id)

      expect {
        application.finish_service_order(command)
      }.to raise_error(Exceptions::ServiceOrderException, "Service order already finished")
    end
  end
end
