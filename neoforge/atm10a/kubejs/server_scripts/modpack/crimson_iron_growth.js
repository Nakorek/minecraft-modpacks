// Custom crops omitted from the pack's AE2 growth tags.
ServerEvents.tags('block', event => {
  event.add('ae2:growth_acceleratable', [
    'mysticalagriculture:crimson_iron_crop',
    'mysticalagriculture:azure_silver_crop'
  ])
  console.info('[custom-crop-growth] Added Crimson Iron and Azure Silver to the AE2 growth accelerator block tag')
})
