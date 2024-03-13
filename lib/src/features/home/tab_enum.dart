enum TabsEnum {
  editVenue,
  addVenue,
  account,
}

TabsEnum? getTabFromString(String tabName) {
  for (var tab in TabsEnum.values) {
    if (tab.toString().split('.').last == tabName.toLowerCase()) {
      return tab;
    }
  }
  return null;
}
