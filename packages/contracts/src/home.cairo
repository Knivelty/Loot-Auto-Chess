use autochessia::models::{
    CreatureProfile, StageProfile, StageProfilePiece, Piece, Player, SynergyProfile
};
use autochessia::customType::{PieceChange, RoundResult, CurseOptionType};


#[dojo::interface]
trait IHome {
    fn initialize();

    // set args
    fn setCreatureProfile(profiles: Array<CreatureProfile>);
    fn setStageProfile(profiles: Array<StageProfile>, pieces: Array<StageProfilePiece>);
    fn setSynergyProfile(profiles: Array<SynergyProfile>);

    fn spawn();
    fn refreshAltar();
    fn buyHero(altarSlot: u8, invSlot: u8);
    fn mergeHero(gid1: u32, gid2: u32, gid3: u32, invSlot: u8);
    fn buyExp();
    fn sellHero(gid: u32);
    fn commitPreparation(changes: Array<PieceChange>, result: RoundResult);
    fn nextRound(choice: CurseOptionType);


    // debug func
    fn getCoin();
    fn exit();
}

use starknet::{
    ContractAddress, Zeroable, contract_address_try_from_felt252, get_caller_address, get_block_info
};


#[dojo::contract]
mod home {
    use core::traits::TryInto;
    use core::option::OptionTrait;
    use core::traits::Into;
    use starknet::{
        ContractAddress, get_caller_address, get_block_hash_syscall, get_block_info, get_tx_info,
        get_block_timestamp
    };
    use autochessia::models::{
        CreatureProfile, Position, Piece, Player, InningBattle, GlobalState, MatchState, Altar,
        PlayerPiece, PlayerInvPiece, StageProfile, StageProfilePiece, LevelConfig, PlayerProfile,
        ChoiceProfile, CurseOption, LevelRarityProb, SynergyProfile
    };

    use autochessia::utils::{
        next_position, generate_pseudo_random_address, generate_pseudo_random_u8,
        generate_pseudo_random, get_felt_mod, gen_piece_gid, roll_rarity, roll_creature
    };
    use autochessia::customType::{PieceChange, RoundResult, CurseOptionType};

    use autochessia::customEvent::{PieceActions, PieceAction};
    use dojo::base;
    use core::poseidon::{PoseidonTrait, poseidon_hash_span};
    use core::hash::{HashStateTrait, HashStateExTrait};
    use super::IHome;


    // declaring custom event struct
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        PieceActions: PieceActions,
    }

    fn _refreshAltar(world: IWorldDispatcher, playerAddr: ContractAddress) {
        let mut player = get!(world, playerAddr, Player);

        // generate pseudo random number on block hash
        // let mut hash = get_block_hash_syscall(get_block_info().unbox().block_number - 10);
        // TODO: change it later
        let hash = get_block_timestamp().into();

        let mut r: felt252 = hash;

        // match hash {
        //     Result::Ok(value) => { r = value.into() },
        //     Result::Err(err) => { panic!("gr error") },
        // }
        let gState = get!(world, 1, GlobalState);

        let slot1 = _roll_piece(world, r);

        let slot2 = _roll_piece(world, slot1.hash);

        let slot3 = _roll_piece(world, slot2.hash);

        let slot4 = _roll_piece(world, slot3.hash);

        let slot5 = _roll_piece(world, slot4.hash);

        // set altar
        set!(
            world,
            (Altar {
                player: playerAddr,
                slot1: slot1.creature_index,
                slot2: slot2.creature_index,
                slot3: slot3.creature_index,
                slot4: slot4.creature_index,
                slot5: slot5.creature_index
            })
        );
    }


    struct RollPieceReturn {
        creature_index: u16,
        hash: felt252
    }

    fn _roll_piece(world: IWorldDispatcher, preHash: felt252) -> RollPieceReturn {
        let playerAddr = get_caller_address();

        let gState = get!(world, 1, GlobalState);
        let player = get!(world, playerAddr, Player);
        let rarityProb = get!(world, player.level, LevelRarityProb);

        let mut hash = PoseidonTrait::new().update(preHash).finalize();

        let rarity = roll_rarity(hash, rarityProb.r1, rarityProb.r2, rarityProb.r3);

        hash = PoseidonTrait::new().update(hash).finalize();

        let creatureCount = match rarity {
            0 => 0,
            1 => gState.totalR1Creature,
            2 => gState.totalR2Creature,
            3 => gState.totalR3Creature,
            _ => 0,
        };

        let creatureId = roll_creature(hash, rarity, creatureCount);

        return RollPieceReturn { creature_index: creatureId, hash: hash };
    }


    fn _validPieceChange(world: IWorldDispatcher, c: @PieceChange) {
        let change = *c;
        let playerAddr = get_caller_address();
        let mut player = get!(world, playerAddr, Player);

        let mut oldPiece = get!(world, change.gid, Piece);

        // TODO: add case by case check
        let mut oldPlayerInvPiece = get!(world, (oldPiece.owner, oldPiece.slot), PlayerInvPiece);
        let mut oldPlayerPiece = get!(world, (oldPiece.owner, oldPiece.idx), PlayerPiece);

        let mut newPlayerInvPiece = get!(world, (oldPiece.owner, change.slot), PlayerInvPiece);
        let mut newPlayerPiece = get!(world, (oldPiece.owner, change.idx), PlayerPiece);

        if (change.gid == 0) {
            panic!("change gid = 0, panic");
        }

        // only piece move on board
        if (oldPiece.slot == 0 && change.slot == 0) { // idx should be the same
        } else if (oldPiece.slot != 0 && change.slot == 0) {
            // move from inv to board

            if (change.idx == 0) {
                panic!("invalid change");
            }

            if (oldPiece.idx != 0) {
                panic!("piece already on board");
            }

            oldPlayerInvPiece.gid = 0;
            newPlayerPiece.gid = change.gid;

            player.heroesCount += 1;
            player.inventoryCount -= 1;

            set!(world, (oldPlayerInvPiece, newPlayerPiece));
        } else if (oldPiece.slot == 0 && change.slot != 0) {
            // move from board to inv

            if (change.idx != 0) {
                panic!("invalid change");
            }

            if (oldPiece.slot != 0) {
                panic!("piece already in inv");
            }

            oldPlayerPiece.gid = 0;
            newPlayerInvPiece.gid = change.gid;

            player.heroesCount -= 1;
            player.inventoryCount += 1;

            set!(world, (oldPlayerPiece, newPlayerInvPiece));
        } else if (oldPiece.slot != 0 && change.slot != 0) {
            // move between two inventory slot

            if (change.idx != 0) {
                panic!("invalid change");
            }

            oldPlayerInvPiece.gid = 0;
            newPlayerInvPiece.gid = change.gid;
            set!(world, (oldPlayerInvPiece, newPlayerInvPiece));
        } else {
            panic!("unknown change");
        }

        // update piece attr
        oldPiece.x = change.x;
        oldPiece.y = change.y;
        oldPiece.slot = change.slot;
        oldPiece.idx = change.idx;

        set!(world, (oldPiece, player));
    }


    fn _spawnEnemyPiece(world: IWorldDispatcher, round: u8, enemyAddr: ContractAddress) {
        let playerAddr = get_caller_address();

        let mut enemyProfile = get!(world, enemyAddr, PlayerProfile);

        // get the current stage profile
        let stageProfile = get!(world, round, StageProfile);

        let lastRound = round - 1;
        // delete old piece
        let lastStageProfile = get!(world, lastRound, StageProfile);

        let mut startIdx = 1;
        let lastPieceCount = lastStageProfile.pieceCount;

        loop {
            if (startIdx > lastPieceCount) {
                break;
            }

            // get old piece
            let mut stalePlayerPiece = get!(world, (enemyAddr, startIdx), PlayerPiece);
            let mut stalePiece = get!(world, (stalePlayerPiece.gid), Piece);

            stalePlayerPiece.gid = 0;
            stalePiece.owner = Zeroable::zero();

            // TODO: fix the bug
            // NOTE: comment the next line because there's a migration error and idk why
            // Difference in FunctionId { id: 68, debug_name: None }: Some(OrderedHashMap({Const: 173730})) != Some(OrderedHashMap({Const: 2260})).
            // Difference in FunctionId { id: 68, debug_name: None }: Some(OrderedHashMap({Const: 173730})) != Some(OrderedHashMap({Const: 2260})).
            set!(world, (stalePlayerPiece));
            set!(world, (stalePiece));

            startIdx += 1;
        };

        // spawn piece according to stage profile
        let mut idx = 1;

        loop {
            let sp = get!(world, (round, idx), StageProfilePiece);
            enemyProfile.pieceCounter += 1;
            let gid = gen_piece_gid(enemyAddr, enemyProfile.pieceCounter);

            set!(
                world,
                (
                    PlayerPiece { owner: enemyAddr, idx: idx, gid: gid },
                    Piece {
                        gid: gid,
                        owner: enemyAddr,
                        idx: idx,
                        slot: 0,
                        level: sp.level,
                        creature_index: sp.creature_index,
                        x: sp.x,
                        y: sp.y,
                    }
                )
            );

            if (idx >= stageProfile.pieceCount) {
                break;
            }
            idx = idx + 1;
        };

        // update heroCount
        let mut enemy = get!(world, enemyAddr, Player);
        enemy.heroesCount = stageProfile.pieceCount;

        set!(world, (enemy, enemyProfile));
    }

    fn _giveRoundCoinReward(world: IWorldDispatcher, dangerous: bool) {
        let playerAddr = get_caller_address();

        let mut player = get!(world, playerAddr, Player);

        // get interest
        let interest = player.coin / 10;

        // get streak reward 
        let streakReward = player.winStreak + player.loseStreak;

        // get round base reward
        let matchState = get!(world, player.inMatch, MatchState);
        let roundBaseReward = matchState.round / 10;

        let mut totalIncome = interest + streakReward + roundBaseReward;

        // dangerous round give 150% coin
        if (dangerous) {
            totalIncome = totalIncome * 3 / 2;
        }

        player.coin += totalIncome;

        // give the free refresh change
        player.refreshed = false;

        set!(world, (player));
    }

    fn _registerPlayer(world: IWorldDispatcher, playerAddr: ContractAddress) {
        let playerProfile = get!(world, playerAddr, PlayerProfile);

        if (playerProfile.pieceCounter == 0) {
            set!(world, PlayerProfile { player: playerAddr, pieceCounter: 0, })
        }
    }

    fn _removePiece(world: IWorldDispatcher, gid: u32) {
        let playerAddr = get_caller_address();
        let mut player = get!(world, playerAddr, Player);
        let mut piece = get!(world, gid, Piece);

        if (piece.slot != 0) {
            // remove this piece from inventory
            set!(world, PlayerInvPiece { owner: playerAddr, slot: piece.slot, gid: 0, });
            player.inventoryCount -= 1;
            set!(world, (player));
        } else if (piece.idx != 0) {
            // remove piece from player piece idx
            if (piece.idx == player.heroesCount) {
                // if the piece is the last piece, just remove it
                set!(world, PlayerPiece { owner: playerAddr, idx: piece.idx, gid: 0, });
            } else {
                // should switch the last piece
                let lastPiece = get!(world, (playerAddr, player.heroesCount), PlayerPiece);

                set!(world, PlayerPiece { owner: playerAddr, idx: piece.idx, gid: lastPiece.gid, });

                set!(
                    world,
                    PlayerPiece { owner: playerAddr, idx: player.heroesCount, gid: lastPiece.gid, }
                );
            }

            player.heroesCount -= 1;
            set!(world, (player));
        } else {
            panic!("logic error");
        }

        // update piece owner
        piece.owner = Zeroable::zero();
        set!(world, (piece));
    }

    fn _rollChoiceType(world: IWorldDispatcher) {
        let playerAddr = get_caller_address();

        let MASK_8: u128 = 0xff;
        let MASK_128: felt252 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        let mut hash: u128 = generate_pseudo_random(get_block_timestamp().into());

        let safe: u8 = ((hash % 5 + 1) & MASK_8).try_into().unwrap();

        hash = generate_pseudo_random(hash.into()).try_into().unwrap();
        let balanced: u8 = ((hash % 5 + 1) & MASK_8).try_into().unwrap();

        hash = generate_pseudo_random(hash.into()).try_into().unwrap();
        let challenge: u8 = ((hash % 5 + 1) & MASK_8).try_into().unwrap();

        // 
        set!(
            world,
            (
                CurseOption { playerAddr: playerAddr, t: CurseOptionType::Safe, order: safe },
                CurseOption {
                    playerAddr: playerAddr, t: CurseOptionType::Balanced, order: balanced
                },
                CurseOption {
                    playerAddr: playerAddr, t: CurseOptionType::Challenge, order: challenge
                }
            )
        );
    }

    fn _settleChoice(world: IWorldDispatcher, choice: CurseOptionType, round: u8) {
        let playerAddr = get_caller_address();
        let mut player = get!(world, playerAddr, Player);

        let co = get!(world, (playerAddr, choice), CurseOption);
        let choiceP = get!(world, (choice, co.order), ChoiceProfile);
        player.coin -= choiceP.coinDec;
        player.coin += choiceP.coinInc;

        if (player.curse > choiceP.curseDec) {
            player.curse -= choiceP.curseDec;
        } else {
            player.curse = 0;
        }
        player.curse += choiceP.curseInc;
        // max curse is 100
        if (player.curse > 100) {
            player.curse = 100;
        }

        // min curse is 10 after round 4
        if (player.curse < 10 && round >= 4) {
            player.curse = 10;
        }

        if (player.danger > choiceP.deterDec) {
            player.danger -= choiceP.deterDec;
        } else {
            player.danger = 0;
        }
        player.danger += choiceP.deterInc;
        player.health -= choiceP.healthDec;

        // reset to zero
        set!(
            world,
            (
                CurseOption { playerAddr: playerAddr, t: CurseOptionType::Safe, order: 0 },
                CurseOption { playerAddr: playerAddr, t: CurseOptionType::Balanced, order: 0 },
                CurseOption { playerAddr: playerAddr, t: CurseOptionType::Challenge, order: 0 }
            )
        );

        set!(world, (player));
    }


    // impl: implement functions specified in trait
    #[abi(embed_v0)]
    impl HomeImpl of IHome<ContractState> {
        // intialize all args
        // TODO: set as real args

        fn initialize(world: IWorldDispatcher) {
            set!(
                world,
                GlobalState {
                    index: 1,
                    totalMatch: 0,
                    totalCreature: 26,
                    totalR1Creature: 10,
                    totalR2Creature: 10,
                    totalR3Creature: 6
                }
            );

            // set level up config
            set!(world, (LevelConfig { current: 1, expForNext: 2 }));
            set!(world, (LevelConfig { current: 2, expForNext: 2 }));
            set!(world, (LevelConfig { current: 3, expForNext: 6 }));
            set!(world, (LevelConfig { current: 4, expForNext: 10 }));
            set!(world, (LevelConfig { current: 5, expForNext: 24 }));
            set!(world, (LevelConfig { current: 6, expForNext: 42 }));
            set!(world, (LevelConfig { current: 7, expForNext: 64 }));
            set!(world, (LevelConfig { current: 8, expForNext: 90 }));
            set!(world, (LevelConfig { current: 9, expForNext: 144 }));

            // set choice profile
            set!(
                world,
                (
                    // pay 3 coin to decrease 40 deter
                    ChoiceProfile {
                        t: CurseOptionType::Safe,
                        idx: 1,
                        coinDec: 3,
                        coinInc: 0,
                        curseDec: 0,
                        curseInc: 0,
                        deterDec: 40,
                        deterInc: 0,
                        healthDec: 0,
                    },
                    // pay 3 coin to decrease 8 curse
                    ChoiceProfile {
                        t: CurseOptionType::Safe,
                        idx: 2,
                        coinDec: 3,
                        coinInc: 0,
                        curseDec: 8,
                        curseInc: 0,
                        deterDec: 0,
                        deterInc: 0,
                        healthDec: 0,
                    },
                    // pay 2 coin to decrease 6 curse
                    ChoiceProfile {
                        t: CurseOptionType::Safe,
                        idx: 3,
                        coinDec: 2,
                        coinInc: 0,
                        curseDec: 6,
                        curseInc: 0,
                        deterDec: 0,
                        deterInc: 0,
                        healthDec: 0,
                    },
                    // pay 1 coin to decrease 4 curse
                    ChoiceProfile {
                        t: CurseOptionType::Safe,
                        idx: 4,
                        coinDec: 1,
                        coinInc: 0,
                        curseDec: 4,
                        curseInc: 0,
                        deterDec: 0,
                        deterInc: 0,
                        healthDec: 0,
                    },
                    // decrease 2 curse
                    ChoiceProfile {
                        t: CurseOptionType::Safe,
                        idx: 5,
                        coinDec: 0,
                        coinInc: 0,
                        curseDec: 2,
                        curseInc: 0,
                        deterDec: 0,
                        deterInc: 0,
                        healthDec: 0,
                    },
                    // get 1 coin and 30 deter
                    ChoiceProfile {
                        t: CurseOptionType::Balanced,
                        idx: 1,
                        coinDec: 0,
                        coinInc: 1,
                        curseDec: 0,
                        curseInc: 30,
                        deterDec: 0,
                        deterInc: 0,
                        healthDec: 0,
                    },
                    // decrease 2 curse
                    ChoiceProfile {
                        t: CurseOptionType::Balanced,
                        idx: 2,
                        coinDec: 0,
                        coinInc: 0,
                        curseDec: 2,
                        curseInc: 0,
                        deterDec: 0,
                        deterInc: 0,
                        healthDec: 0,
                    },
                    // get 2 curse
                    ChoiceProfile {
                        t: CurseOptionType::Balanced,
                        idx: 3,
                        coinDec: 0,
                        coinInc: 0,
                        curseDec: 0,
                        curseInc: 2,
                        deterDec: 0,
                        deterInc: 0,
                        healthDec: 0,
                    },
                    // get 1 coin and 3 curse
                    ChoiceProfile {
                        t: CurseOptionType::Balanced,
                        idx: 4,
                        coinDec: 0,
                        coinInc: 1,
                        curseDec: 0,
                        curseInc: 3,
                        deterDec: 0,
                        deterInc: 0,
                        healthDec: 0,
                    },
                    // pay 2 coin
                    ChoiceProfile {
                        t: CurseOptionType::Balanced,
                        idx: 5,
                        coinDec: 0,
                        coinInc: 2,
                        curseDec: 0,
                        curseInc: 0,
                        deterDec: 0,
                        deterInc: 0,
                        healthDec: 0,
                    },
                    // get 15 deter
                    ChoiceProfile {
                        t: CurseOptionType::Challenge,
                        idx: 1,
                        coinDec: 0,
                        coinInc: 0,
                        curseDec: 0,
                        curseInc: 0,
                        deterDec: 0,
                        deterInc: 15,
                        healthDec: 0,
                    },
                    // pay 1 to increase 6 curse
                    ChoiceProfile {
                        t: CurseOptionType::Challenge,
                        idx: 2,
                        coinDec: 1,
                        coinInc: 0,
                        curseDec: 0,
                        curseInc: 6,
                        deterDec: 0,
                        deterInc: 0,
                        healthDec: 0,
                    },
                    // get 3 coin and increase 100 deter
                    ChoiceProfile {
                        t: CurseOptionType::Challenge,
                        idx: 3,
                        coinDec: 0,
                        coinInc: 3,
                        curseDec: 0,
                        curseInc: 0,
                        deterDec: 0,
                        deterInc: 100,
                        healthDec: 0,
                    },
                    // pay 5 coin to get 15 curse
                    ChoiceProfile {
                        t: CurseOptionType::Challenge,
                        idx: 4,
                        coinDec: 5,
                        coinInc: 0,
                        curseDec: 0,
                        curseInc: 15,
                        deterDec: 0,
                        deterInc: 0,
                        healthDec: 0,
                    },
                    // pay 6 health to get 10 curse and 100 deter
                    ChoiceProfile {
                        t: CurseOptionType::Challenge,
                        idx: 5,
                        coinDec: 0,
                        coinInc: 0,
                        curseDec: 0,
                        curseInc: 10,
                        deterDec: 0,
                        deterInc: 100,
                        healthDec: 6,
                    }
                )
            );

            // set refresh LevelRarityProb
            set!(
                world,
                (
                    LevelRarityProb { level: 1, r1: 100, r2: 0, r3: 0 },
                    LevelRarityProb { level: 2, r1: 100, r2: 0, r3: 0 },
                    LevelRarityProb { level: 3, r1: 80, r2: 20, r3: 0 },
                    LevelRarityProb { level: 4, r1: 65, r2: 35, r3: 0 },
                    LevelRarityProb { level: 5, r1: 60, r2: 40, r3: 0 },
                    LevelRarityProb { level: 6, r1: 50, r2: 45, r3: 5 },
                    LevelRarityProb { level: 7, r1: 45, r2: 45, r3: 10 },
                    LevelRarityProb { level: 8, r1: 40, r2: 45, r3: 15 },
                    LevelRarityProb { level: 9, r1: 35, r2: 45, r3: 20 },
                    LevelRarityProb { level: 10, r1: 35, r2: 35, r3: 30 },
                )
            )
        }

        fn setCreatureProfile(world: IWorldDispatcher, profiles: Array<CreatureProfile>) {
            let mut idx = 0;
            let length = profiles.len();

            loop {
                if (idx >= length) {
                    break;
                }
                let p = profiles.at(idx);
                set!(world, (*p));
                idx += 1;
            };
        }


        fn setSynergyProfile(world: IWorldDispatcher, profiles: Array<SynergyProfile>) {
            let mut idx = 0;
            let length = profiles.len();

            loop {
                if (idx >= length) {
                    break;
                }
                let p = profiles.at(idx);
                set!(world, (*p));
                idx += 1;
            };
        }


        fn setStageProfile(
            world: IWorldDispatcher, profiles: Array<StageProfile>, pieces: Array<StageProfilePiece>
        ) {
            let mut idx = 0;
            let length = profiles.len();

            loop {
                if (idx >= length) {
                    break;
                }
                let p = profiles.at(idx);
                set!(world, (*p));
                idx += 1;
            };

            idx = 0;
            let length = pieces.len();

            loop {
                if (idx >= length) {
                    break;
                }
                let p = pieces.at(idx);
                set!(world, (*p));
                idx += 1;
            };
        }


        // ContractState is defined by system decorator expansion
        fn spawn(world: IWorldDispatcher) {
            let playerAddr = get_caller_address();
            // get player's enemy address

            let hash = get_tx_info().unbox().nonce;
            let enemyAddr = generate_pseudo_random_address(playerAddr.into(), hash);

            // create match
            let mut globalState = get!(world, 1, GlobalState);
            let currentMatch = globalState.totalMatch + 1;
            globalState.totalMatch = currentMatch;

            set!(
                world,
                (
                    MatchState {
                        index: currentMatch, round: 1, player1: playerAddr, player2: enemyAddr
                    },
                    globalState
                )
            );

            // spawn player
            set!(
                world,
                Player {
                    player: playerAddr,
                    health: 100,
                    heroesCount: 0,
                    inventoryCount: 0,
                    level: 1,
                    coin: 1,
                    exp: 0,
                    winStreak: 0,
                    loseStreak: 0,
                    locked: 0,
                    inMatch: currentMatch,
                    refreshed: false,
                    curse: 0,
                    danger: 0,
                }
            );
            _registerPlayer(world, playerAddr);

            // refresh hero altar
            _refreshAltar(world, playerAddr);

            // get the first stage profile
            let stageProfile = get!(world, 1, StageProfile);

            // spawn enemy
            set!(
                world,
                Player {
                    player: enemyAddr,
                    health: 10,
                    heroesCount: stageProfile.pieceCount,
                    inventoryCount: 0,
                    level: 1,
                    coin: 0,
                    exp: 0,
                    winStreak: 0,
                    loseStreak: 0,
                    locked: 0,
                    inMatch: currentMatch,
                    refreshed: false,
                    curse: 0,
                    danger: 0,
                }
            );
            _registerPlayer(world, playerAddr);

            // spawn enemy piece
            _spawnEnemyPiece(world, 1, enemyAddr);

            // create battle
            set!(
                world,
                (
                    InningBattle {
                        currentMatch: currentMatch,
                        round: 1,
                        homePlayer: playerAddr,
                        awayPlayer: enemyAddr,
                        end: false,
                        winner: Zeroable::zero(),
                        healthDecrease: 0,
                        dangerous: false
                    },
                ),
            );
        }


        fn mergeHero(world: IWorldDispatcher, gid1: u32, gid2: u32, gid3: u32, invSlot: u8) {
            // validate piece
            let playerAddr = get_caller_address();

            let piece1 = get!(world, gid1, Piece);
            let piece2 = get!(world, gid2, Piece);
            let piece3 = get!(world, gid3, Piece);

            // check piece owner
            if (piece1.owner != playerAddr
                || piece2.owner != playerAddr
                || piece3.owner != playerAddr) {
                panic!("pieces owner not player");
            }

            // check piece creature idx
            if (!(piece1.creature_index == piece2.creature_index
                && piece2.creature_index == piece3.creature_index)) {
                panic!("piece creature idx not consistent");
            }

            // check piece level
            if (!(piece1.level == piece2.level && piece2.level == piece3.level)) {
                panic!("piece level not consistent");
            }

            if (piece1.level > 2) {
                panic!("piece level capped")
            }

            // remove the three merged pieces
            _removePiece(world, gid1);
            _removePiece(world, gid2);
            _removePiece(world, gid3);

            // gen new piece 
            let mut playerProfile = get!(world, playerAddr, PlayerProfile);
            playerProfile.pieceCounter += 1;
            set!(world, (playerProfile));
            let gid = gen_piece_gid(playerAddr, playerProfile.pieceCounter);

            let mut playerV = get!(world, playerAddr, Player);
            playerV.inventoryCount += 1;

            // spawn Piece
            set!(
                world,
                (
                    Piece {
                        gid: gid,
                        owner: playerAddr,
                        idx: 0,
                        slot: invSlot,
                        level: piece1.level + 1,
                        creature_index: piece1.creature_index,
                        x: 0,
                        y: 0
                    },
                    PlayerInvPiece { owner: playerAddr, slot: invSlot, gid: gid, },
                    playerV
                )
            );
        }

        // commit preparation in one function
        // include: refresh, move
        // the contract side need to valid the validity
        fn commitPreparation(
            world: IWorldDispatcher, changes: Array<PieceChange>, result: RoundResult
        ) {
            let playerAddr = get_caller_address();

            let mut idx = 0;
            let length = changes.len();

            // check each progress
            loop {
                if (idx >= length) {
                    break;
                }

                let change = changes.at(idx);
                _validPieceChange(world, change);

                idx = idx + 1;
            };

            // mark battle as end
            let mut player = get!(world, playerAddr, Player);
            let matchState = get!(world, player.inMatch, MatchState);
            let mut inningBattle = get!(world, (matchState.index, matchState.round), InningBattle);

            if (result.win) {
                inningBattle.winner = inningBattle.homePlayer;

                // update streak 
                if (player.winStreak != 0) {
                    player.winStreak += 1;
                    player.loseStreak = 0;
                } else {
                    player.winStreak = 1;
                    player.loseStreak = 0;
                }
            } else {
                inningBattle.winner = inningBattle.awayPlayer;
                // decrease health
                if (player.health > result.healthDecrease) {
                    player.health -= result.healthDecrease
                } else {
                    player.health = 0;
                }

                // update streak 
                if (player.winStreak != 0) {
                    player.winStreak = 1;
                    player.loseStreak = 0;
                } else {
                    player.winStreak = 0;
                    player.loseStreak += 1;
                }
            }
            inningBattle.healthDecrease = result.healthDecrease;
            inningBattle.end = true;

            set!(world, (inningBattle, player));

            _rollChoiceType(world);
        }

        fn refreshAltar(world: IWorldDispatcher) {
            let playerAddr = get_caller_address();

            let mut player = get!(world, playerAddr, Player);

            // use the free refresh chance or pay
            if (!player.refreshed) {
                player.refreshed = true;
            } else {
                // player coin minus 1
                player.coin -= 2;
            }

            set!(world, (player));

            _refreshAltar(world, playerAddr);
        }

        fn buyExp(world: IWorldDispatcher) {
            let playerAddr = get_caller_address();
            let mut player = get!(world, playerAddr, Player);

            player.exp += 4;
            player.coin -= 4;
            let levelConfig = get!(world, player.level, LevelConfig);

            // loop twice
            if (player.exp >= levelConfig.expForNext) {
                player.level += 1;
                player.exp -= levelConfig.expForNext;
            }

            if (player.exp >= levelConfig.expForNext) {
                player.level += 1;
                player.exp -= levelConfig.expForNext;
            }

            set!(world, (player));
        }

        fn buyHero(world: IWorldDispatcher, altarSlot: u8, invSlot: u8) {
            let playerAddr = get_caller_address();

            let mut player = get!(world, playerAddr, Player);
            let mut altar = get!(world, playerAddr, Altar);
            let mut playerProfile = get!(world, playerAddr, PlayerProfile);
            playerProfile.pieceCounter += 1;

            // get creature Id
            let creatureId = match altarSlot.into() {
                0 => { 0 },
                1 => {
                    let creatureId = altar.slot1;
                    altar.slot1 = 0;
                    creatureId
                },
                2 => {
                    let creatureId = altar.slot2;
                    altar.slot2 = 0;
                    creatureId
                },
                3 => {
                    let creatureId = altar.slot3;
                    altar.slot3 = 0;
                    creatureId
                },
                4 => {
                    let creatureId = altar.slot4;
                    altar.slot4 = 0;
                    creatureId
                },
                5 => {
                    let creatureId = altar.slot5;
                    altar.slot5 = 0;
                    creatureId
                },
                _ => { 0 }
            };
            // check whether is empty
            if (creatureId == 0) {
                panic!("invalid creature");
            }

            // get creature profile
            let creatureProfile = get!(world, (creatureId, 1), CreatureProfile);

            // player coin minus 1
            player.coin -= creatureProfile.rarity;
            player.inventoryCount += 1;

            // check wether this slot is full
            let playerInvPiece = get!(world, (playerAddr, invSlot), PlayerInvPiece);
            if (playerInvPiece.gid != 0) {
                panic!("this slot occupied")
            }

            let gid = gen_piece_gid(playerAddr, playerProfile.pieceCounter);

            // spwan piece
            set!(
                world,
                (
                    Piece {
                        gid: gid,
                        owner: playerAddr,
                        idx: 0,
                        slot: invSlot,
                        level: 1,
                        creature_index: creatureId,
                        x: 0,
                        y: 0
                    },
                    PlayerInvPiece { owner: playerAddr, slot: invSlot, gid: gid },
                    playerProfile,
                    altar,
                    player
                )
            )
        // 
        }

        fn sellHero(world: IWorldDispatcher, gid: u32) {
            let playerAddr = get_caller_address();

            let mut piece = get!(world, gid, Piece);
            let mut invPiece = get!(world, (playerAddr, piece.slot), PlayerInvPiece);
            let mut player = get!(world, playerAddr, Player);

            if (invPiece.gid == 0) {
                panic!("empty slot, cannot sell");
            }

            // refund coin
            // TODO: judge by level
            player.coin += 1;
            player.inventoryCount -= 1;

            // by default, consider the piece are sold from inv
            // TODO: delete! will break torii https://github.com/dojoengine/dojo/issues/1635
            // delete!(world, (piece));

            // set gid equal 0 to mark it as deleted
            invPiece.gid = 0;
            piece.slot = 0;
            piece.idx = 0;
            piece.owner = Zeroable::zero();
            set!(world, (invPiece, piece));

            set!(world, (player));
        }

        fn nextRound(world: IWorldDispatcher, choice: CurseOptionType) {
            let playerAddr = get_caller_address();

            let mut player = get!(world, playerAddr, Player);
            let mut currentMatchState = get!(world, player.inMatch, MatchState);

            // settle player's choice
            _settleChoice(world, choice, currentMatchState.round);

            let lastInningBattle = get!(
                world, (player.inMatch, currentMatchState.round), InningBattle
            );

            let currentRound = currentMatchState.round;
            let newRound = currentRound + 1;
            currentMatchState.round = newRound;

            // get new piece
            let enemyAddr = lastInningBattle.awayPlayer;
            _spawnEnemyPiece(world, currentRound + 1, enemyAddr);

            // get cursed on round 4
            if (newRound == 4) {
                player.curse += 10;
            }

            // increase danger by curse
            player.danger += player.curse;

            let mut dangerous = false;
            // judge whether next round is a dangerous round
            if (player.danger >= 100) {
                player.danger -= 100;
                dangerous = true;
            }

            set!(
                world,
                (
                    // update match state
                    currentMatchState,
                    // create battle
                    InningBattle {
                        currentMatch: currentMatchState.index,
                        round: newRound,
                        homePlayer: playerAddr,
                        awayPlayer: lastInningBattle.awayPlayer,
                        end: false,
                        winner: Zeroable::zero(),
                        healthDecrease: 0,
                        dangerous: dangerous
                    }
                ),
            );

            // update exp and try level up
            if (dangerous) {
                player.exp += 3;
            } else {
                player.exp += 2;
            }
            let levelConfig = get!(world, player.level, LevelConfig);
            if (player.exp >= levelConfig.expForNext) {
                player.level += 1;
                player.exp -= levelConfig.expForNext;
            }
            set!(world, (player));

            // add more coin
            _giveRoundCoinReward(world, dangerous);
        }


        fn getCoin(world: IWorldDispatcher) {
            let playerAddr = get_caller_address();

            let mut player = get!(world, playerAddr, Player);
            player.coin += 10;

            set!(world, (player));
        }

        // exit current game
        fn exit(world: IWorldDispatcher) {
            let playerAddr = get_caller_address();

            let mut player = get!(world, playerAddr, Player);
            let mut idx = 1;

            // delete player inv piece
            loop {
                if (idx > player.level) {
                    break;
                }
                let mut playerInvPiece = get!(world, (playerAddr, idx), PlayerInvPiece);
                let mut piece = get!(world, playerInvPiece.gid, Piece);

                playerInvPiece.gid = 0;
                piece.owner = Zeroable::zero();
                set!(world, (playerInvPiece, piece));

                idx += 1;
            };

            // delete player piece
            idx = 1;
            loop {
                if (player.heroesCount < idx) {
                    break;
                }
                let mut playerPiece = get!(world, (playerAddr, idx), PlayerPiece);
                let mut piece = get!(world, playerPiece.gid, Piece);

                playerPiece.gid = 0;
                piece.owner = Zeroable::zero();
                set!(world, (playerPiece, piece));

                idx += 1;
            };
            // reset player attr
            set!(
                world,
                Player {
                    player: playerAddr,
                    health: 0,
                    heroesCount: 0,
                    inventoryCount: 0,
                    level: 0,
                    coin: 0,
                    exp: 0,
                    winStreak: 0,
                    loseStreak: 0,
                    locked: 0,
                    inMatch: 0,
                    refreshed: false,
                    curse: 0,
                    danger: 0,
                }
            );
        }
    }
}

#[cfg(test)]
mod tests {
    use starknet::class_hash::Felt252TryIntoClassHash;

    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    // import test utils
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    // import models
    use autochessia::models::{Player, player, Piece, piece, InningBattle, inning_battle};

    // import home
    use super::{home, IHomeDispatcher, IHomeDispatcherTrait};

    use debug::PrintTrait;

    #[test]
    #[available_gas(10000000000)]
    fn test_spwan() { // caller
        let caller = starknet::contract_address_const::<0x0>();

        // models
        let mut models = array![
            player::TEST_CLASS_HASH, piece::TEST_CLASS_HASH, inning_battle::TEST_CLASS_HASH
        ];

        // deploy world with models
        let world = spawn_test_world(models);
        // deploy systems contract
        let contract_address = world
            .deploy_contract('salt', home::TEST_CLASS_HASH.try_into().unwrap());
        let home_system = IHomeDispatcher { contract_address };

        // initialize
        home_system.initialize();

        // call spawn()
        home_system.spawn();

        // Check world state
        let player = get!(world, caller, Player);

        // check health
        assert(player.health == 100, 'health not right');

        // check inning battle
        let iBattle = get!(world, (1, 1), InningBattle);

        assert(iBattle.homePlayer == caller, 'home player not true');
    }
}
