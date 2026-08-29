// Uses /Hat - Puts item you are holding onto your head
ServerEvents.commandRegistry(event => {
  const { commands: Commands } = event;
  
  event.register(
    Commands.literal('hat').executes(ctx => {
      let player = ctx.source.player;
      
      if (player) {
        let handItem = player.mainHandItem.copy();
        let headItem = player.headArmorItem.copy();
        
        player.headArmorItem = handItem;
        player.mainHandItem = headItem;
      }
      
      return 1;
    })
  );
});