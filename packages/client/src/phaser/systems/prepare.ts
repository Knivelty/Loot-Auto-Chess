import {
    Entity,
    Has,
    defineSystem,
    defineEnterSystem,
    getComponentValueStrict,
    UpdateType,
} from "@dojoengine/recs";
import { PhaserLayer } from "..";
import { tileCoordToPixelCoord } from "@latticexyz/phaserx";
import { Sprites, TILE_HEIGHT, TILE_WIDTH } from "../config/constants";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { addAddressPadding, getChecksumAddress } from "starknet";

export const prepare = (layer: PhaserLayer) => {
    const {
        world,
        scenes: {
            Main: { config, objectPool },
        },
        networkLayer: {
            contractComponents: { Piece, InningBattle },
            account,
        },
    } = layer;

    // defineEnterSystem(world, [Has(Piece)], ({ entity }: any) => {
    //     const playerObj = objectPool.get(entity.toString(), "Sprite");

    //     console.log(playerObj);

    //     playerObj.setComponent({
    //         id: "animation",
    //         once: (sprite: any) => {
    //             console.log(sprite);
    //             sprite.play(Animations.RockIdle);
    //         },
    //     });
    // });

    defineSystem(world, [Has(Piece)], ({ entity, type }) => {
        if (type === UpdateType.Enter) {
            const piece = getComponentValueStrict(
                Piece,
                entity.toString() as Entity
            );

            const offsetPosition = { x: piece.x_board, y: piece.y_board };
            const pixelPosition = tileCoordToPixelCoord(
                offsetPosition,
                TILE_WIDTH,
                TILE_HEIGHT
            );
            const hero = objectPool.get(entity, "Sprite");

            // remove non owned piece
            if (piece.owner != BigInt(account.address)) {
                return;
            }

            // console.log("prepare entity: ", entity);

            hero.setComponent({
                id: entity,
                once: (sprite: Phaser.GameObjects.Sprite) => {
                    sprite.setPosition(pixelPosition?.x, pixelPosition?.y);

                    sprite.play(config.animations[piece.internal_index]);

                    // TODO: use lossless scale method
                    const scale = TILE_WIDTH / sprite.width;
                    sprite.setScale(scale);
                },
            });
        }
    });
};
