#ifndef FLUTTER_PLUGIN_SENTC_LIGHT_PLUGIN_H_
#define FLUTTER_PLUGIN_SENTC_LIGHT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace sentc_light {

class SentcLightPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  SentcLightPlugin();

  virtual ~SentcLightPlugin();

  // Disallow copy and assign.
  SentcLightPlugin(const SentcLightPlugin&) = delete;
  SentcLightPlugin& operator=(const SentcLightPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace sentc_light

#endif  // FLUTTER_PLUGIN_SENTC_LIGHT_PLUGIN_H_
