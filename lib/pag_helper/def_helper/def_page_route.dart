import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

enum PagPageRoute {
  projectPublicFront(
    'Project Public Front',
    'project_public_front',
    Symbols.flag_filled_rounded,
  ),
  splash(
    'Splash',
    'splash',
    Symbols.pending,
  ),
  home(
    'Home',
    'home',
    Symbols.home,
  ),
  login(
    'Login',
    'login',
    Symbols.login,
  ),
  register(
    'Register',
    'register',
    Symbols.person_add,
  ),
  myProfile(
    'Profile',
    'profile',
    Symbols.person,
  ),
  consoleHomeDashboard(
    'Home',
    'console_home_dashboard',
    Symbols.home,
  ),
  consoleHomeUserService(
    'User Service',
    'user_service',
    Symbols.person,
  ),
  consoleHomeAcl(
    'Role & Access',
    'console_home_acl',
    Symbols.admin_panel_settings,
  ),
  consoleHomeSettings(
    'Settings',
    'console_home_settings',
    Symbols.settings,
  ),
  consoleHomeTaskManager(
    'Task Manager',
    'console_home_task_manager',
    Symbols.overview,
  ),
  meterManager(
    'Meter Manager',
    'meter_manager',
    Symbols.speed,
  ),
  evsMeterManager(
    'Meter Manager',
    'evs_meter_manager',
    Symbols.speed,
  ),
  meterGroupManager(
    'Meter Group Manager',
    'meter_group_manager',
    Symbols.atr,
  ),

  creditTransaction(
    'Credit Transaction',
    'credit_transaction',
    Symbols.credit_card,
  ),
  tenantManager(
    'Tenant Manager',
    'tenant_manager',
    Symbols.location_away,
  ),
  evsTenantManager(
    'Tenant Manager',
    'evs_tenant_manager',
    Symbols.location_away,
  ),
  tariffManager(
    'Tariff Manager',
    'tariff_manager',
    Symbols.price_change,
  ),
  billingManager(
    'Billing Manager',
    'billing_manager',
    Symbols.request_quote,
  ),
  paymentManager(
    'Payment Manager',
    'payment_manager',
    Symbols.attach_money,
  ),
  landlordManager(
    'Landlord Manager',
    'landlord_manager',
    Symbols.home_work,
  ),
  evsDashboard(
    'EVS',
    'evs_dashboard',
    Symbols.grid_view,
  ),
  evsTaskReportManager(
    'Task/Report Manager',
    'evs_task_report_manager',
    Symbols.energy_program_time_used,
  ),
  emsDashboard(
    'EMS',
    'ems_dashboard',
    Symbols.grid_view,
  ),
  emsTaskReportManager(
    'Task/Report Manager',
    'ems_task_report_manager',
    Symbols.overview,
  ),
  lockManager(
    'Lock Manager',
    'lock_manager',
    Symbols.lock,
  ),
  ptwDashboard(
    'PTW',
    'ptw_dashboard',
    Symbols.grid_view,
  ),
  ptwWorkSiteManager(
    'Work Site Manager',
    'ptw_work_site_manager',
    Symbols.home_pin,
  ),
  ptwApplicationManager(
    'Application Manager',
    'ptw_application_manager',
    Symbols.passkey,
  ),
  ptwWorkOrderManager(
    'Work Order Manager',
    'ptw_work_order_manager',
    Symbols.admin_panel_settings,
  ),
  ptwTaskReportManager(
    'Task/Report Manager',
    'ptw_task_report_manager',
    Symbols.overview,
  ),
  cameraManager(
    'Camera Manager',
    'camera_manager',
    Symbols.videocam,
  ),
  vmDashboard(
    'VM',
    'vm_dashboard',
    Symbols.grid_view,
  ),
  vmEventManager(
    'Event Manager',
    'vm_event_manager',
    Symbols.event_list,
  ),
  vmTaskReportManager(
    'Task/Report Manager',
    'vm_task_report_manager',
    Symbols.overview,
  ),
  fhDashboard(
    'FH',
    'fh_dashboard',
    Symbols.grid_view,
  ),
  fhDeviceManager(
    'FH',
    'fh_device_manager',
    Symbols.home_iot_device,
  ),
  fhEventManager(
    'Event Manager',
    'fh_event_manager',
    Symbols.event_list,
  ),
  fhTaskReportManager(
    'Task/Report Manager',
    'fh_task_report_manager',
    Symbols.overview,
  ),
  bmsDashboard(
    'BMS',
    'bms_dashboard',
    Symbols.grid_view,
  ),
  amDashboard(
    'Asset Management',
    'am_dashboard',
    Symbols.grid_view,
  ),
  cmDashboard(
    'Condition Minitoring',
    'cm_dashboard',
    Symbols.grid_view,
  ),
  cmDeviceManager(
    'Device Manager',
    'cm_device_manager',
    Symbols.home_iot_device,
  ),
  amScopeManager(
    'Scope Manager',
    'am_scope_manager',
    Symbols.file_map_stack,
  ),
  amCommsManager(
    'Comms Manager',
    'am_comms_manager',
    Symbols.join,
  ),
  amDeviceManager(
    'Device Manager',
    'am_device_manager',
    Symbols.home_iot_device,
  ),
  pqDashboard(
    'PQ',
    'pq_dashboard',
    Symbols.grid_view,
  ),
  pqInsights(
    'PQ Insights',
    'pq_insights',
    Symbols.airwave,
  ),
  ctLab(
    'CT Lab',
    'ctlab',
    Symbols.airwave,
  ),
  esDashboard(
    'ES',
    'es_dashboard',
    Symbols.grid_view,
  ),
  esInsights(
    'ES Insights',
    'es_insights',
    Symbols.developer_board,
  ),
  about(
    'About',
    'about',
    Symbols.info,
  ),
  contact(
    'Contact',
    'contact',
    Symbols.contact_support,
  ),
  terms(
    'Terms',
    'terms',
    Symbols.contract,
  ),
  privacy(
    'Privacy',
    'privacy',
    Symbols.privacy,
  ),
  help(
    'Help',
    'help',
    Symbols.help,
  ),
  faq(
    'FAQ',
    'faq',
    Symbols.quiz,
  ),
  feedback(
    'Feedback',
    'feedback',
    Symbols.feedback,
  ),
  none(
    '',
    '',
    Symbols.error_outline,
  ),
  techIssue(
    'techIssue',
    'techIssue',
    Symbols.assignment_late,
  ),
  forgotPassword(
    'Forgot Password',
    'forgot_password',
    Symbols.lock,
  ),
  resetPassword(
    'Reset Password',
    'reset_password',
    Symbols.restart_alt,
  );

  const PagPageRoute(
    this.label,
    this.route,
    this.iconData,
  );

  final String label;
  final String route;
  final IconData iconData;

  static PagPageRoute byLabel(String? label) =>
      enumByLabel(label, values) ?? none;
}

T? enumByLabel<T extends Enum>(String? label, List<T> values) {
  return label == null ? null : values.asNameMap()[label];
}

String getRoute(PagPageRoute pageRoute) {
  String? route;

  // iterate thru each route enum
  for (var pageRouteInfo in PagPageRoute.values) {
    if (pageRouteInfo == pageRoute) {
      route = pageRouteInfo.route;
      break;
    }
  }
  if (route == null) {
    throw Exception('Route not found');
  }
  //add / if route is not start with /
  if (!route.startsWith('/')) {
    route = '/$route';
  }
  return route;
}

// String getRoute(PagPageRoute pageRoute) {
//   String? route;

//   for (var pageRouteInfo in routeList) {
//     if (pageRouteInfo['pageRoute'] == pageRoute) {
//       route = pageRouteInfo['route'] as String;
//       break;
//     }
//   }
//   if (route == null) {
//     throw Exception('Route not found');
//   }
//   //add / if route is not start with /
//   if (!route.startsWith('/')) {
//     route = '/$route';
//   }
//   return route;
// }

String getPageTitle(PagPageRoute pageRoute) {
  String? pageTitle;

  // iterate thru each route enum
  for (var pageRouteInfo in PagPageRoute.values) {
    if (pageRouteInfo == pageRoute) {
      pageTitle = pageRouteInfo.label;
      break;
    }
  }
  if (pageTitle == null) {
    throw Exception('Page title not found');
  }
  return pageTitle;
}

// String getPageTitle(PagPageRoute pageRoute) {
//   String? pageTitle;

//   for (var pageRouteInfo in routeList) {
//     if (pageRouteInfo['pageRoute'] == pageRoute) {
//       pageTitle = pageRouteInfo['pageTitle'] as String;
//       break;
//     }
//   }
//   if (pageTitle == null) {
//     throw Exception('Page title not found');
//   }
//   return pageTitle;
// }

Map<String, dynamic> getMenueItem(PagPageRoute page) {
  Map<String, dynamic> menueItem = {};

  // iterate thru each route enum
  for (var pageRouteInfo in PagPageRoute.values) {
    if (pageRouteInfo == page) {
      menueItem = {
        'pr': pageRouteInfo,
        'label': pageRouteInfo.label,
        'route': pageRouteInfo.route,
      };
      break;
    }
  }
  if (menueItem.isEmpty) {
    throw Exception('Menue item not found. page: $page');
  }
  return menueItem;
}

// Map<String, dynamic> getMenueItem(PagPageRoute page) {
//   Map<String, dynamic> menueItem = {};

//   for (var pageRouteInfo in routeList) {
//     if (pageRouteInfo['pageRoute'] == page) {
//       menueItem = {
//         'pr': pageRouteInfo['pageRoute'],
//         'label': pageRouteInfo['menueLabel'] ?? pageRouteInfo['pageTitle'],
//         'route': pageRouteInfo['route'],
//       };
//       break;
//     }
//   }
//   if (menueItem.isEmpty) {
//     throw Exception('Menue item not found. page: $page');
//   }
//   return menueItem;
// }
