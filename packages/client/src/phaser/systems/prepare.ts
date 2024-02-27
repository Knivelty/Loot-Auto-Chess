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
        const piece = getComponentValueStrict(
            Piece,
            entity.toString() as Entity
        );

        if (type === UpdateType.Enter) {
            let offsetPosition = { x: piece.x_board, y: piece.y_board };

            if (BigInt(account.address) !== piece.owner) {
                console.log("offsetPosition: ", offsetPosition);
                offsetPosition = {
                    x: 8 - offsetPosition.x,
                    y: 8 - offsetPosition.x,
                };
                console.log("offsetPosition: ", offsetPosition);
            }

            const pixelPosition = tileCoordToPixelCoord(
                offsetPosition,
                TILE_WIDTH,
                TILE_HEIGHT
            );
            const hero = objectPool.get(entity, "Sprite");

            // console.log("prepare entity: ", entity);

            hero.setComponent({
                id: entity,
                once: (sprite: Phaser.GameObjects.Sprite) => {
                    console.log("pixelPosition: ", pixelPosition);
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