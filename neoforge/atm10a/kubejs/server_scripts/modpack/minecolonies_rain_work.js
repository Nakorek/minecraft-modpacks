// Keep Roshar's rain-work setting across fresh installs and config regeneration.
ServerEvents.loaded(event => {
  const api = Java.loadClass('com.minecolonies.api.IMinecoloniesAPI')
  const configs = api.getInstance().getConfig()
  const rainWork = configs.getServer().workersAlwaysWorkInRain

  if (!rainWork.get()) {
    configs.set(rainWork, true)
  }

  console.info('[minecolonies-rain-work] workersalwaysworkinrain = true')
})
