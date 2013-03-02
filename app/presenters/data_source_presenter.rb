class DataSourcePresenter < Presenter
  def to_hash
    {
        :name => model.name,
        :host => model.host,
        :port => model.port,
        :id => model.id,
        :shared => model.shared,
        :online => model.state == "online",
        :db_name => model.db_name,
        :description => model.description,
        :version => model.version,
        :entity_type => model.entity_type_name,
        :tags => present(model.tags),
    }.merge(owner_hash)
  end


  private

  def owner_hash
    if rendering_activities?
      {}
    else
      {:owner => present(model.owner)}
    end
  end
end