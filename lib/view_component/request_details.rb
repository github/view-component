# frozen_string_literal: true

module ViewComponent
  # LookupContext computes and encapsulates @details for each request
  # so that it doesn't need to be recomputed on each partial render.
  # This data is wrapped in ActionView::TemplateDetails::Requested and
  # used by instances of ActionView::Resolver to choose which template
  # best matches the request.
  #
  # ActionView considers this logic internal to template/partial resolution.
  # We're exposing it to the compiler via `refine` so that ViewComponent
  # can match Rails' template picking logic.
  module RequestDetails
    refine ActionView::LookupContext do
      # Return an abstraction for matching and sorting available templates
      # based on the current lookup context details.
      #
      # @return ActionView::TemplateDetails::Requested
      # @see ActionView::LookupContext#detail_args_for
      # @see ActionView::FileSystemResolver#_find_all
      def vc_requested_details(user_details = {})
        # The hash `user_details` would normally be the standard arguments that
        # `render` accepts, but there's currently no mechanism for users to
        # provide these when calling render on a ViewComponent.
        details, cached = detail_args_for(user_details)
        cached || ActionView::TemplateDetails::Requested.new(**details)
      end
    end
  end
end
