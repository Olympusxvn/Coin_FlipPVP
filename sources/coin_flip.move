module coin_flip::coin_flip {

    use sui::tx_context::{Self, TxContext};
    use sui::coin::Coin;
    use sui::sui::SUI;
    use sui::transfer;
    use sui::object::{Self, UID};
    use std::vector;

    /// Struct lưu thông tin game
    struct Game has key, store {
        id: UID,
        player: address,
        bet: Coin<SUI>,
    }

    /// Tạo game mới
    public entry fun create_game(bet: Coin<SUI>, ctx: &mut TxContext) {
        let game = Game {
            id: object::new(ctx),
            player: tx_context::sender(ctx),
            bet,
        };
        transfer::public_transfer(game, tx_context::sender(ctx));
    }

    /// Lật coin
    public entry fun flip(game: Game, opponent_bet: Coin<SUI>, ctx: &mut TxContext) {
        let opponent = tx_context::sender(ctx);

        // Lấy hash từ context (reference)
        let hash = tx_context::digest(ctx);
        let first_byte = *vector::borrow(hash, 0);
        let outcome = first_byte % 2;

        // Move toàn bộ struct ra để tránh copy lỗi
        let Game { id, player, bet } = game;

        if (outcome == 0) {
            // Người tạo game thắng
            transfer::public_transfer(bet, player);
            transfer::public_transfer(opponent_bet, player);
        } else {
            // Đối thủ thắng
            transfer::public_transfer(bet, opponent);
            transfer::public_transfer(opponent_bet, opponent);
        };

        // Destroy the game object since it's no longer needed
        object::delete(id);
    }
}
