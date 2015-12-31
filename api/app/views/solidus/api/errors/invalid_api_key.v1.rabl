object false
node(:error) { I18n.t(:invalid_api_key, :key => api_key, :scope => "solidus.api") }
