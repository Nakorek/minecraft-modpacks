// Keep all claimed colony chunks loaded while an owner/officer is nearby.
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

  console.info('[minecolonies-chunk-loading] forceloadcolony = true; colonyloadstrictness = 1')
})
