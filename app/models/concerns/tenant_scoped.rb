# Provides a helper to scope queries to the current organization.
# Included automatically in ApplicationRecord for models that have organization_id.
module TenantScoped
  extend ActiveSupport::Concern

  class_methods do
    def by_organization(org)
      where(organization_id: org.id)
    end
  end
end
