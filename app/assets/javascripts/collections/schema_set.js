chorus.collections.SchemaSet = chorus.collections.Base.include(
    chorus.Mixins.InstanceCredentials.model
).extend({
    constructorName: "SchemaSet",
    model:chorus.models.Schema,
    urlTemplate:"instances/{{instance_id}}/databases/{{database_id}}/schemas",

    comparator:function (schema) {
        return schema.get('name').toLowerCase();
    },

    parse:function (resp) {
        var resource = this._super("parse", arguments);
        return _.map(resource, function (model) {
            return _.extend({
                instance_id: this.attributes.instance_id,
                instanceName: this.attributes.instanceName
            }, model)
        }, this)
    }
});
