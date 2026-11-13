import 'package:flutter/material.dart';

/// Colors of the states that Material 3 does not define: success, warning and info.
/// The error state uses `ColorScheme.error`.

@immutable
class StatusColors extends ThemeExtension<StatusColors>{
  const StatusColors({
    required this.success,
    required this.warning,
    required this.info,
  });
  
  final Color success;
  final Color warning;
  final Color info;
  
  static const light = StatusColors(
      success: Color(0xFF10B981),
      warning: Color(0xFFF59E0B),
      info: Color(0xFF3B82F6)
  );

  @override
  StatusColors copyWith({Color? success, Color? warning, Color? info}){
    return StatusColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        info: info ?? this.info
    );
  }

  @override
  StatusColors lerp(StatusColors? other, double t){
    if (other is! StatusColors) return this;
    return StatusColors(
        success: Color.lerp(success, other.success, t)!,
        warning: Color.lerp(warning, other.warning, t)!,
        info:Color.lerp(info, other.info, t)!,
    );
  }
  
}