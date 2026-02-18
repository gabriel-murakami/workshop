class ServiceOrderMailer < ApplicationMailer
  default from: ENV["SMTP_USERNAME"]

  def status_updated(service_order)
    @service_order = service_order
    @customer = customer

    mail(
      to: customer[:email],
      subject: "Ordem de Serviço - Atualização de Status"
    )
  end

  def pending_payment(service_order)
    @service_order = service_order
    @customer = customer
    @payment = payment

    mail(
      to: customer[:email],
      subject: "Ordem de Serviço - Pagamento Pendente"
    )
  end

  private

  def payment
    Domain::ServiceOrder::Payment.find_by(service_order_id: @service_order.id)
  end

  def customer
    Application::Customer::CustomerApplication.new.find(@service_order.customer_id)
  end
end
