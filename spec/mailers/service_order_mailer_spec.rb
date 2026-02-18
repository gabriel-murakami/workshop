require "rails_helper"

RSpec.describe ServiceOrderMailer, type: :mailer do
  describe "#pending_payment" do
    let(:service_order) { create(:service_order) }

    let(:customer_response) do
      {
        email: "cliente@example.com",
        name: "João"
      }
    end

    let(:payment) do
      double(
        "Payment",
        id: 123,
        amount: 250.0,
        status: "pending",
        provider_payload: { "init_point" => "http//checkout.com" }
      )
    end

    let(:customer_application) { double("CustomerApplication") }

    before do
      allow(Application::Customer::CustomerApplication)
        .to receive(:new)
        .and_return(customer_application)

      allow(customer_application)
        .to receive(:find)
        .with(service_order.customer_id)
        .and_return(customer_response)

      allow(Domain::ServiceOrder::Payment)
        .to receive(:find_by)
        .with(service_order_id: service_order.id)
        .and_return(payment)
    end

    let(:mail) { described_class.pending_payment(service_order) }

    it "renders the headers" do
      expect(mail.subject).to eq("Ordem de Serviço - Pagamento Pendente")
      expect(mail.to).to eq([ customer_response[:email] ])
    end

    it "renders the body with order info" do
      body = mail.body.encoded

      expect(body).to include(service_order.id.to_s)
      expect(body).to include(customer_response[:name])
    end
  end
end
