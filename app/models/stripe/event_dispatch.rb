require 'stripe/event'
module Stripe
  module EventDispatch
    def dispatch_stripe_event(request)
      retrieve_stripe_event(request) do |evt|
        target = evt.data.object
        ::Stripe::Callbacks.run_callbacks(evt, target)
      end
    end

    def retrieve_stripe_event(request)
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      endpoint_secret = ENV['STRIPE_WEBHOOK_SIGNATURE']
      id = params['id']
      if id == 'evt_00000000000000' #this is a webhook test
        yield Stripe::Event.construct_from(params.to_unsafe_h)
      else
        yield Stripe::Webhook.construct_event(
          payload, sig_header, endpoint_secret
        )
      end
    end
  end
end
