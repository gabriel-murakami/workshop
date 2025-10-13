class ServiceOrderMailer < ApplicationMailer
  default from: ENV["SMTP_USERNAME"]

  def status_updated(service_order)
    @service_order = service_order
    @customer = service_order.customer

    mail(
      to: @customer.email,
      subject: "Atualização da Ordem de Serviço"
    )
  end
end
