import Component from "@glimmer/component";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

export default class SuppressFromLatest extends Component {
  @service siteSettings;

  <template>
    <@outletArgs.form.Section
      @title={{i18n "category.suppress_settings_label"}}
      class="category-custom-settings-outlet suppress-from-latest-settings"
    >
      {{#if this.siteSettings.suppress_categories_from_latest_enabled}}
        <@outletArgs.form.Object @name="custom_fields" as |customFields|>
          <customFields.Field
            @name="suppress_category_from_latest"
            @title={{i18n "category.suppress_enabled"}}
            @format="max"
            @type="checkbox"
            as |field|
          >
            <field.Control />
          </customFields.Field>
        </@outletArgs.form.Object>
      {{else}}
        <div class="field">
          {{i18n "category.suppress_disabled"}}
          <a
            href="/admin/site_settings/category/plugins?filter=suppress_categories_from_latest"
          >
            {{i18n "category.suppress_disabled_link"}}
          </a>
        </div>
      {{/if}}
    </@outletArgs.form.Section>
  </template>
}
