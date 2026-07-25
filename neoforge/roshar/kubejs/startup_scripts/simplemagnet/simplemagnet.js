StartupEvents.registry('item', event => {
  event.create('simplemagnet:simple_magnet')
    .displayName('Simple Magnet')
    .unstackable()
    .tooltip('Shift-Right-Click to toggle');
});