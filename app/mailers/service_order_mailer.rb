class ServiceOrderMailer < ApplicationMailer
  default from: ENV["SMTP_USERNAME"]

  def status_updated(service_order, customer, vehicle)
    @service_order = service_order
    @customer = customer
    @vehicle = vehicle

    mail(
      to: @customer[:email],
      subject: "Atualização da Ordem de Serviço"
    )
  end
end
