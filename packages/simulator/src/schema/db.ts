import { RxDatabase } from "rxdb";
import { CreatureTypeCollection } from "./creature";
import { BattleEntityTypeCollection } from "./battle_entity";
import { BaseStateTypeCollection } from "./base_state";
import { PieceAttackTypeCollection } from "./attack";
import { PieceMaxHealthCollection } from "./maxHealth";
import { EffectTypeCollection } from "./effect";
import { AbilityProfileTypeCollection } from "./ability_profile";

export type DBCollections = {
  creature: CreatureTypeCollection;
  battle_entity: BattleEntityTypeCollection;
  ability_profile: AbilityProfileTypeCollection;
  base_state: BaseStateTypeCollection;
  piece_attack: PieceAttackTypeCollection;
  piece_max_health: PieceMaxHealthCollection;
  effect: EffectTypeCollection;
};

export type MyDatabase = RxDatabase<DBCollections>;
