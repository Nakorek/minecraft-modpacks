// Keep claimed colony chunks loaded while an owner/officer is nearby and for 24 hours after leaving.
ServerEvents.loaded(event => {
  const api = Java.loadClass('com.minecolonies.api.IMinecoloniesAPI')
  const integer = Java.loadClass('java.lang.Integer')
  const configs = api.getInstance().getConfig()
  const server = configs.getServer()

  if (!server.forceLoadColony.get()) {
    configs.set(server.forceLoadColony, true)
  }

  if (server.colonyLoadStrictness.get() != 1) {
    configs.set(server.colonyLoadStrictness, integer.valueOf(1))
  }

  if (server.loadtime.get() != 1440) {
    configs.set(server.loadtime, integer.valueOf(1440))
  }

  console.info('[minecolonies-chunk-loading] forceloadcolony = true; colonyloadstrictness = 1; loadtime = 1440 minutes')
})
