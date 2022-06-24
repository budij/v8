include(ExternalProject)

set(DepotToolsUrl "https://chromium.googlesource.com/chromium/tools/depot_tools.git")

ExternalProject_Add(
   ${DepotToolsProjectName}
   GIT_REPOSITORY  ${DepotToolsUrl}
   GIT_TAG main
   GIT_SHALLOW YES
   GIT_PROGRESS YES
   SOURCE_DIR ${DepotToolsSource}
   CONFIGURE_COMMAND ""
   BUILD_COMMAND ""
   INSTALL_COMMAND ""
   UPDATE_COMMAND ""
)
