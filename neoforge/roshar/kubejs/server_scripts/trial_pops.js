LootJS.modifiers(event => {
    const pops = [
        'justcreatepop:azu_pop', 
        'justcreatepop:beardy_pop', 
        'justcreatepop:block_pop', 
        'justcreatepop:chosen_pop', 
        'justcreatepop:dave_pop', 
        'justcreatepop:deo_pop', 
        'justcreatepop:eggs_pop', 
        'justcreatepop:foxy_pop', 
        'justcreatepop:frog_pop', 
        'justcreatepop:silent_pop', 
        'justcreatepop:stam_pop', 
        'justcreatepop:thro_pop', 
        'justcreatepop:vee_pop',
        'justcreatepop:kev_pop',
        'justcreatepop:rofo_pop'
    ];

    event.addTableModifier([
        "minecraft:chests/trial_chambers/reward",
        "minecraft:chests/trial_chambers/reward_ominous"
    ])
    .pool(pool => {
        pool.rolls(1);
        pops.forEach(popId => {
            pool.addEntry(LootEntry.of(popId)); 
        });
    });
});