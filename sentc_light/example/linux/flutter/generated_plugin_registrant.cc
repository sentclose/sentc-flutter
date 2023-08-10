//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <sentc_light/sentc_light_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) sentc_light_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SentcLightPlugin");
  sentc_light_plugin_register_with_registrar(sentc_light_registrar);
}
