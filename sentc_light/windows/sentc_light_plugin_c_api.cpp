#include "include/sentc_light/sentc_light_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "sentc_light_plugin.h"

void SentcLightPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  sentc_light::SentcLightPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
