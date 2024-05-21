// Generated by dojo-bindgen on Mon, 8 Apr 2024 13:47:52 +0000. Do not modify this file manually.
import { defineComponent, Type as RecsType, World } from "@dojoengine/recs";

export type ContractComponents = Awaited<
            ReturnType<typeof defineContractComponents>
        >;



// Type definition for `autochessia::models::LevelConfig` struct
export interface LevelConfig {
    current: number;
    expForNext: number;
    
}

export const LevelConfigDefinition = {
    current: RecsType.Number,
    expForNext: RecsType.Number,
    
};


// Type definition for `autochessia::models::MatchState` struct
export interface MatchState {
    index: number;
    round: number;
    player1: bigint;
    player2: bigint;
    
}

export const MatchStateDefinition = {
    index: RecsType.Number,
    round: RecsType.Number,
    player1: RecsType.BigInt,
    player2: RecsType.BigInt,
    
};


// Type definition for `autochessia::models::Piece` struct
export interface Piece {
    gid: number;
    owner: bigint;
    idx: number;
    slot: number;
    level: number;
    creature_index: number;
    x: number;
    y: number;
    
}

export const PieceDefinition = {
    gid: RecsType.Number,
    owner: RecsType.BigInt,
    idx: RecsType.Number,
    slot: RecsType.Number,
    level: RecsType.Number,
    creature_index: RecsType.Number,
    x: RecsType.Number,
    y: RecsType.Number,
    
};


// Type definition for `autochessia::models::Player` struct
export interface Player {
    player: bigint;
    inMatch: number;
    health: number;
    winStreak: number;
    loseStreak: number;
    coin: number;
    exp: number;
    level: number;
    locked: number;
    heroesCount: number;
    inventoryCount: number;
    refreshed: boolean
    
}

export const PlayerDefinition = {
    player: RecsType.BigInt,
    inMatch: RecsType.Number,
    health: RecsType.Number,
    winStreak: RecsType.Number,
    loseStreak: RecsType.Number,
    coin: RecsType.Number,
    exp: RecsType.Number,
    level: RecsType.Number,
    locked: RecsType.Number,
    heroesCount: RecsType.Number,
    inventoryCount: RecsType.Number,
    refreshed: RecsType.Boolean,
    
};


// Type definition for `autochessia::models::PlayerInvPiece` struct
export interface PlayerInvPiece {
    owner: bigint;
    slot: number;
    gid: number;
    
}

export const PlayerInvPieceDefinition = {
    owner: RecsType.BigInt,
    slot: RecsType.Number,
    gid: RecsType.Number,
    
};


// Type definition for `autochessia::models::Vec2` struct
export interface Vec2 {
    x: number;
    y: number;
    
}

export const Vec2Definition = {
    x: RecsType.Number,
    y: RecsType.Number,
    
};

// Type definition for `autochessia::models::Position` struct
export interface Position {
    player: bigint;
    vec: Vec2;
    
}

export const PositionDefinition = {
    player: RecsType.BigInt,
    vec: Vec2Definition,
    
};


// Type definition for `autochessia::models::PlayerProfile` struct
export interface PlayerProfile {
    player: bigint;
    pieceCounter: number;
    
}

export const PlayerProfileDefinition = {
    player: RecsType.BigInt,
    pieceCounter: RecsType.Number,
    
};


// Type definition for `autochessia::models::StageProfile` struct
export interface StageProfile {
    stage: number;
    pieceCount: number;
    
}

export const StageProfileDefinition = {
    stage: RecsType.Number,
    pieceCount: RecsType.Number,
    
};


// Type definition for `autochessia::models::StageProfilePiece` struct
export interface StageProfilePiece {
    stage: number;
    index: number;
    x: number;
    y: number;
    creature_index: number;
    level: number;
    
}

export const StageProfilePieceDefinition = {
    stage: RecsType.Number,
    index: RecsType.Number,
    x: RecsType.Number,
    y: RecsType.Number,
    creature_index: RecsType.Number,
    level: RecsType.Number,
    
};


// Type definition for `autochessia::models::InningBattle` struct
export interface InningBattle {
    currentMatch: number;
    round: number;
    homePlayer: bigint;
    awayPlayer: bigint;
    end: boolean
    winner: bigint;
    healthDecrease: number;
    
}

export const InningBattleDefinition = {
    currentMatch: RecsType.Number,
    round: RecsType.Number,
    homePlayer: RecsType.BigInt,
    awayPlayer: RecsType.BigInt,
    end: RecsType.Boolean,
    winner: RecsType.BigInt,
    healthDecrease: RecsType.Number,
    
};


// Type definition for `autochessia::models::PlayerPiece` struct
export interface PlayerPiece {
    owner: bigint;
    idx: number;
    gid: number;
    
}

export const PlayerPieceDefinition = {
    owner: RecsType.BigInt,
    idx: RecsType.Number,
    gid: RecsType.Number,
    
};


// Type definition for `autochessia::models::CreatureProfile` struct
export interface CreatureProfile {
    creature_index: number;
    level: number;
    rarity: number;
    health: number;
    attack: number;
    armor: number;
    range: number;
    speed: number;
    initiative: number;
    
}

export const CreatureProfileDefinition = {
    creature_index: RecsType.Number,
    level: RecsType.Number,
    rarity: RecsType.Number,
    health: RecsType.Number,
    attack: RecsType.Number,
    armor: RecsType.Number,
    range: RecsType.Number,
    speed: RecsType.Number,
    initiative: RecsType.Number,
    
};


// Type definition for `autochessia::models::Altar` struct
export interface Altar {
    player: bigint;
    slot1: number;
    slot2: number;
    slot3: number;
    slot4: number;
    slot5: number;
    
}

export const AltarDefinition = {
    player: RecsType.BigInt,
    slot1: RecsType.Number,
    slot2: RecsType.Number,
    slot3: RecsType.Number,
    slot4: RecsType.Number,
    slot5: RecsType.Number,
    
};


// Type definition for `autochessia::models::GlobalState` struct
export interface GlobalState {
    index: number;
    totalMatch: number;
    totalCreature: number;
    
}

export const GlobalStateDefinition = {
    index: RecsType.Number,
    totalMatch: RecsType.Number,
    totalCreature: RecsType.Number,
    
};


export function defineContractComponents(world: World) {
    return {

        // Model definition for `autochessia::models::LevelConfig` model
        LevelConfig: (() => {
            return defineComponent(
                world,
                {
                    current: RecsType.Number,
                    expForNext: RecsType.Number,
                },
                {
                    metadata: {
                        name: "LevelConfig",
                        types: ["u8", "u8"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `autochessia::models::MatchState` model
        MatchState: (() => {
            return defineComponent(
                world,
                {
                    index: RecsType.Number,
                    round: RecsType.Number,
                    player1: RecsType.BigInt,
                    player2: RecsType.BigInt,
                },
                {
                    metadata: {
                        name: "MatchState",
                        types: ["u32", "u8", "ContractAddress", "ContractAddress"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `autochessia::models::Piece` model
        Piece: (() => {
            return defineComponent(
                world,
                {
                    gid: RecsType.Number,
                    owner: RecsType.BigInt,
                    idx: RecsType.Number,
                    slot: RecsType.Number,
                    level: RecsType.Number,
                    creature_index: RecsType.Number,
                    x: RecsType.Number,
                    y: RecsType.Number,
                },
                {
                    metadata: {
                        name: "Piece",
                        types: ["u32", "ContractAddress", "u8", "u8", "u8", "u8", "u8", "u8"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `autochessia::models::Player` model
        Player: (() => {
            return defineComponent(
                world,
                {
                    player: RecsType.BigInt,
                    inMatch: RecsType.Number,
                    health: RecsType.Number,
                    winStreak: RecsType.Number,
                    loseStreak: RecsType.Number,
                    coin: RecsType.Number,
                    exp: RecsType.Number,
                    level: RecsType.Number,
                    locked: RecsType.Number,
                    heroesCount: RecsType.Number,
                    inventoryCount: RecsType.Number,
                    refreshed: RecsType.Boolean,
                },
                {
                    metadata: {
                        name: "Player",
                        types: ["ContractAddress", "u32", "u8", "u8", "u8", "u8", "u8", "u8", "u8", "u8", "u8", "bool"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `autochessia::models::PlayerInvPiece` model
        PlayerInvPiece: (() => {
            return defineComponent(
                world,
                {
                    owner: RecsType.BigInt,
                    slot: RecsType.Number,
                    gid: RecsType.Number,
                },
                {
                    metadata: {
                        name: "PlayerInvPiece",
                        types: ["ContractAddress", "u8", "u32"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `autochessia::models::Position` model
        Position: (() => {
            return defineComponent(
                world,
                {
                    player: RecsType.BigInt,
                    vec: Vec2Definition,
                },
                {
                    metadata: {
                        name: "Position",
                        types: ["ContractAddress"],
                        customTypes: ["Vec2"],
                    },
                }
            );
        })(),

        // Model definition for `autochessia::models::PlayerProfile` model
        PlayerProfile: (() => {
            return defineComponent(
                world,
                {
                    player: RecsType.BigInt,
                    pieceCounter: RecsType.Number,
                },
                {
                    metadata: {
                        name: "PlayerProfile",
                        types: ["ContractAddress", "u32"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `autochessia::models::StageProfile` model
        StageProfile: (() => {
            return defineComponent(
                world,
                {
                    stage: RecsType.Number,
                    pieceCount: RecsType.Number,
                },
                {
                    metadata: {
                        name: "StageProfile",
                        types: ["u8", "u8"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `autochessia::models::StageProfilePiece` model
        StageProfilePiece: (() => {
            return defineComponent(
                world,
                {
                    stage: RecsType.Number,
                    index: RecsType.Number,
                    x: RecsType.Number,
                    y: RecsType.Number,
                    creature_index: RecsType.Number,
                    level: RecsType.Number,
                },
                {
                    metadata: {
                        name: "StageProfilePiece",
                        types: ["u8", "u8", "u8", "u8", "u8", "u8"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `autochessia::models::InningBattle` model
        InningBattle: (() => {
            return defineComponent(
                world,
                {
                    currentMatch: RecsType.Number,
                    round: RecsType.Number,
                    homePlayer: RecsType.BigInt,
                    awayPlayer: RecsType.BigInt,
                    end: RecsType.Boolean,
                    winner: RecsType.BigInt,
                    healthDecrease: RecsType.Number,
                },
                {
                    metadata: {
                        name: "InningBattle",
                        types: ["u32", "u8", "ContractAddress", "ContractAddress", "bool", "ContractAddress", "u8"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `autochessia::models::PlayerPiece` model
        PlayerPiece: (() => {
            return defineComponent(
                world,
                {
                    owner: RecsType.BigInt,
                    idx: RecsType.Number,
                    gid: RecsType.Number,
                },
                {
                    metadata: {
                        name: "PlayerPiece",
                        types: ["ContractAddress", "u8", "u32"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `autochessia::models::CreatureProfile` model
        CreatureProfile: (() => {
            return defineComponent(
                world,
                {
                    creature_index: RecsType.Number,
                    level: RecsType.Number,
                    rarity: RecsType.Number,
                    health: RecsType.Number,
                    attack: RecsType.Number,
                    armor: RecsType.Number,
                    range: RecsType.Number,
                    speed: RecsType.Number,
                    initiative: RecsType.Number,
                },
                {
                    metadata: {
                        name: "CreatureProfile",
                        types: ["u8", "u8", "u8", "u16", "u16", "u16", "u8", "u8", "u8"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `autochessia::models::Altar` model
        Altar: (() => {
            return defineComponent(
                world,
                {
                    player: RecsType.BigInt,
                    slot1: RecsType.Number,
                    slot2: RecsType.Number,
                    slot3: RecsType.Number,
                    slot4: RecsType.Number,
                    slot5: RecsType.Number,
                },
                {
                    metadata: {
                        name: "Altar",
                        types: ["ContractAddress", "u8", "u8", "u8", "u8", "u8"],
                        customTypes: [],
                    },
                }
            );
        })(),

        // Model definition for `autochessia::models::GlobalState` model
        GlobalState: (() => {
            return defineComponent(
                world,
                {
                    index: RecsType.Number,
                    totalMatch: RecsType.Number,
                    totalCreature: RecsType.Number,
                },
                {
                    metadata: {
                        name: "GlobalState",
                        types: ["u32", "u32", "u8"],
                        customTypes: [],
                    },
                }
            );
        })(),
    };
}
