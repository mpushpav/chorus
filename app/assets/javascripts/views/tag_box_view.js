chorus.views.TagBox = chorus.views.Base.extend({
    templateName: "tag_box",
    constructorName: "TagBoxView",
    subviews: {'.tags_input': 'tagsInput'},

    setup: function() {
        this.requiredResources.add(this.model);
        this.tags = this.model.tags();
        this.tagsInput = new chorus.views.TagsInput({tags: this.tags});
        this.bindings.add(this.tags, "add", this.saveTags);
        this.bindings.add(this.tags, "remove", this.saveTags);
    },

    resourcesLoaded: function() {
        this.tags.reset(this.model.get("tags"));
    },

    saveTags: function() {
        this.tags.save();
    }
});