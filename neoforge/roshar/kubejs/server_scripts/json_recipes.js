 // Copper Oxidized
ServerEvents.recipes(event => {
    const copperItems = Ingredient.of(/.*(copper|lightning_rod).*/).itemIds

    copperItems.forEach(inputId => {
        let outputId = ''

        if (/weathered_/.test(inputId)) {
            outputId = inputId.replace('weathered_', 'oxidized_')
        } 
        else if (/exposed_/.test(inputId)) {
            outputId = inputId.replace('exposed_', 'weathered_')
        } 
        else if (!/exposed_|weathered_|oxidized_/.test(inputId)) {
            
            if (inputId === 'minecraft:copper_block') {
                outputId = 'minecraft:exposed_copper'
            } 
            else if (inputId === 'minecraft:cut_copper') {
                outputId = 'minecraft:exposed_cut_copper'
            }
            else {
                outputId = inputId.replace(':', ':exposed_')
            }
        }

        if (outputId !== '' && Item.exists(outputId)) {
            
            event.custom({
                type: "create:filling",
                ingredients: [
                    { item: inputId },
                    { 
                        type: "neoforge:single", 
                        amount: 250, 
                        fluid: "minecraft:water" 
                    }
                ],
                results: [
                    { id: outputId }
                ]
            })
        }
    })
});

//Copper Waxing
ServerEvents.recipes(event => {
    const rawItems = Ingredient.of(/.*(copper|lightning_rod).*/).itemIds

    const uniqueItems = []
    rawItems.forEach(id => {
        let stringId = String(id) 
        if (!uniqueItems.includes(stringId)) {
            uniqueItems.push(stringId)
        }
    })

    uniqueItems.forEach(inputId => {
        if (inputId.includes('waxed_')) return;

        let outputId = inputId.replace(':', ':waxed_')

        if (Item.exists(outputId)) {
            
            event.remove({ 
                type: "create:deploying", 
                output: outputId,
                not: { mod: "kubejs" } 
            })

            let safeName = outputId.replace(':', '_')

            event.custom({
                type: "create:deploying",
                ingredients: [
                    { item: inputId },
                    { item: "minecraft:honeycomb_block" } 
                ],
                keep_held_item: true,
                results: [
                    { id: outputId }
                ]
            }).id(`kubejs:waxing_deploying_block_${safeName}`) 
        }
    })
});

//Copper Unwax
ServerEvents.recipes(event => {
    const whitelist = [
        'minecraft:waxed_copper_bars',
        'minecraft:waxed_copper_chain',
        'minecraft:waxed_copper_lantern',
        'minecraft:waxed_lightning_rod',
        'minecraft:waxed_copper_chest',
        'minecraft:waxed_copper_golem_statue',
        'copperagebackport:waxed_copper_button'
    ];

    const weatherStages = ['', 'exposed_', 'weathered_', 'oxidized_'];

    whitelist.forEach(baseId => {
        weatherStages.forEach(stage => {
            let inputId = baseId.replace(':waxed_', `:waxed_${stage}`);
            
            let outputId = inputId.replace('waxed_', '');

            if (Item.exists(inputId) && Item.exists(outputId)) {
                
                let hasDeploying = false;
                let hasPolishing = false;

                event.forEachRecipe({ type: "create:deploying", output: outputId }, recipe => {
                    hasDeploying = true;
                });
                
                event.forEachRecipe({ type: "create:sandpaper_polishing", output: outputId }, recipe => {
                    hasPolishing = true;
                });

                let safeName = outputId.replace(':', '_');

                if (!hasDeploying) {
                    event.custom({
                        type: "create:deploying",
                        ingredients: [
                            { item: inputId },
                            { tag: "minecraft:axes" }
                        ],
                        keep_held_item: true,
                        results: [
                            { id: outputId }
                        ]
                    }).id(`kubejs:unwax_deploying_${safeName}`);
                }

                if (!hasPolishing) {
                    event.custom({
                        type: "create:sandpaper_polishing",
                        ingredients: [
                            { item: inputId }
                        ],
                        results: [
                            { id: outputId }
                        ]
                    }).id(`kubejs:unwax_polishing_${safeName}`);
                }
            }
        });
    });
});

// Converts Vibrant Vaults to Deco Shipping Containers then back to Vaults
ServerEvents.recipes(event => {
    const colors = [
        'white', 'light_gray', 'gray', 'black', 
        'brown', 'red', 'orange', 'yellow', 
        'lime', 'green', 'cyan', 'light_blue', 
        'blue', 'purple', 'magenta', 'pink'
    ];

    colors.forEach(color => {
        
        event.custom({
            type: 'minecraft:blasting',
            category: 'misc',
            ingredient: {
                item: `create_vibrant_vaults:${color}_item_vault`
            },
            result: {
                id: `createdeco:${color}_shipping_container`,
                count: 1
            },
            experience: 0.0,
            cookingtime: 100
        }).id(`kubejs:bulk_blasting/${color}_vault_to_shipping_container`);

        event.custom({
            type: 'create:pressing',
            ingredients: [
                {
                    item: `createdeco:${color}_shipping_container`
                }
            ],
            results: [
                {
                    id: `create_vibrant_vaults:${color}_item_vault`, 
                    count: 1
                }
            ]
        }).id(`kubejs:pressing/${color}_shipping_container_to_vault`);
        
    });
});

ServerEvents.recipes(event => {

 // Item Application
event.custom({
 type: "create:item_application",
  ingredients: [
    {
      item: "minecraft:glass"
    },
    {
      item: "create:refined_radiance"
    }
  ],
  results:[
    {
      item:{
        id:"create:refined_radiance_casing"
      }
    }
  ]
});

event.custom({
 type: "create:item_application",
  ingredients: [
    {
      item: "minecraft:obsidian"
    },
    {
      item: "create:shadow_steel"
    }
  ],
  results:[
    {
      item:{
        id:"create:shadow_steel_casing"
      }
    }
  ]
});

  // Washing

event.custom({
  type: "create:splashing",
  ingredients: [
    {
      item: "minecraft:mud"
    }
  ],
  results: [
    {
      chance: 0.5,
      id: "minecraft:hanging_roots"
    }
  ]
});

// Haunting

event.custom({
  type: "create:haunting",
  ingredients: [
    {
      item: "minecraft:charcoal"
    }
  ],
  results: [
    {
      chance: 0.666,
      id: "minecraft:coal"
    }
  ]
});

event.custom({
  type: "create:haunting",
  ingredients: [
    {
      item: "minecraft:dark_oak_log"
    }
  ],
  results: [
    {
      id: "minecraft:pale_oak_log"
    }
  ]
});

event.custom({
  type: "create:haunting",
  ingredients: [
    {
      item: "minecraft:dark_oak_sapling"
    }
  ],
  results: [
    {
      id: "minecraft:pale_oak_sapling"
    }
  ]
});

event.custom({
  type: "create:haunting",
  ingredients: [
    {
      item: "minecraft:moss_block"
    }
  ],
  results: [
    {
      id: "minecraft:pale_moss_block"
    }
  ]
});

event.custom({
  type: "create:haunting",
  ingredients: [
    {
      item: "minecraft:moss_carpet"
    }
  ],
  results: [
    {
      id: "minecraft:pale_moss_carpet"
    }
  ]
});

event.custom({
  type: "create:haunting",
  ingredients: [
    {
      item: "minecraft:vine"
    }
  ],
  results: [
    {
      id: "minecraft:pale_hanging_moss"
    }
  ]
});

event.custom({
  type: "create:haunting",
  ingredients: [
    {
      item: "minecraft:dark_oak_leaves"
    }
  ],
  results: [
    {
      id: "minecraft:pale_oak_leaves"
    }
  ]
});

// Mixing

event.custom({
   type: "create:compacting",
   heat_requirement: "heated",
  ingredients: [
    {
      item: "minecraft:bone_meal"
    },
    {
      type: "neoforge:single",
      amount: 1000,
      fluid: "minecraft:water"
    }
  ],
  results: [
    {
      id: "minecraft:calcite"
    }
  ]
});

event.custom({
   type: "create:compacting",
   heat_requirement: "superheated",
  ingredients: [
    {
      item: "create:powdered_obsidian"
    },
    {
      item: "create:powdered_obsidian"
    },
    {
      item: "create:powdered_obsidian"
    },
    {
      item: "minecraft:glowstone_dust"
    },
    {
      item: "minecraft:glowstone_dust"
    },
    {
      item: "minecraft:glowstone_dust"
    },
    {
      item: "create:polished_rose_quartz"
    }
  ],
  results: [
    {
      id: "create:chromatic_compound"
    }
  ]
});

// Crafter

event.custom({
  type: "create:mechanical_crafting",
  accept_mirrored: false,
  category: "misc",
  key: {
    A: {
      item: "create:cogwheel"
    },
    B: {
      item: "create:brass_ingot"
    },
    C: {
      item: "create:encased_fan"
    },
    D: {
      item: "create:fluid_tank"
    },
    E: {
      item: "minecraft:elytra"
    },
    F: {
      item: "create:blaze_burner"
    },
  },
  pattern: [
    "ABABA",
    "CDEDC",
    " BFB "
  ],
  result: {
    count: 1,
    id: "create_sa:brass_jetpack_chestplate"
  },
  show_notification: false
});

 // Crushing

event.custom({
  type: "create:crushing",
  ingredients: [
    {
      item: "minecraft:deepslate"
    }
  ],
  processing_time: 250,
  results: [
    {
      count: 1,
      id: "minecraft:cobbled_deepslate"
    }
  ]
})

  // Assembly

event.custom({
  type: "create:sequenced_assembly",
  ingredient: {
    item: "minecraft:phantom_membrane"
  },
  results: [
    {
      count: 32,
      id: "railways:track_phantom"
    }
  ],
  sequence: [
    {
      type: "create:deploying",
      ingredients: [
        {
          item: "railways:track_incomplete_phantom"
        },
        {
          tag: "c:ingots/iron"
        }
      ],
      results: [
        {
          id: "railways:track_incomplete_phantom"
        }
      ]
    },
    {
      type: "create:deploying",
      ingredients: [
        {
          item: "railways:track_incomplete_phantom"
        },
        {
          tag: "c:ingots/iron"
        }
      ],
      results: [
        {
          id: "railways:track_incomplete_phantom"
        }
      ]
    },
    {
      type: "create:pressing",
      ingredients: [
        {
          item: "railways:track_incomplete_phantom"
        }
      ],
      results: [
        {
          id: "railways:track_incomplete_phantom"
        }
      ]
    }
  ],
  transitional_item: {
    id: "railways:track_incomplete_phantom"
  }
});

})