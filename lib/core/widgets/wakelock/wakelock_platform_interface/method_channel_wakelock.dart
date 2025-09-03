import 'package:taxi/core/widgets/wakelock/wakelock_platform_interface/messages.dart';
import 'package:taxi/core/widgets/wakelock/wakelock_platform_interface/wake_lock_platform_interface.dart';

class MethodChannelWakelock extends WakelockPlatformInterface {
  final _api = WakelockApi();

  @override
  Future<bool> get enabled async {
    final message = await _api.isEnabled();

    return message.enabled!;
  }

  @override
  Future<void> toggle({required bool enable}) async {
    final message = ToggleMessage();
    message.enable = enable;

    await _api.toggle(message);
  }
}