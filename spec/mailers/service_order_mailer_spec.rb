# spec/mailers/service_order_mailer_spec.rb
require "rails_helper"

RSpec.describe ServiceOrderMailer, type: :mailer do
  describe "#status_updated" do
    let(:customer) { create(:customer, email: "cliente@example.com", name: "João") }
    let(:vehicle) { create(:vehicle, customer: customer) }
    let(:service_order) { create(:service_order, customer: customer, vehicle: vehicle, status: "in_progress") }

    let(:mail) { ServiceOrderMailer.status_updated(service_order) }

    it "renders the headers" do
      expect(mail.subject).to eq("Atualização da Ordem de Serviço")
      expect(mail.to).to eq([ customer.email ])
      expect(mail.from).to eq(ENV["SMTP_USERNAME"])
    end

    it "renders the body with order info" do
      body = mail.body.encoded
      expect(body).to include(service_order.id.to_s)
      expect(body).to include(service_order.status.humanize)
      expect(body).to include(vehicle.license_plate)
      expect(body).to include(customer.name)
    end
  end
end
