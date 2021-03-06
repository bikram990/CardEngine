//
// Created by Erik Little on 4/3/18.
//

import Foundation
import NIO
import Kit

/// The game of The Builders.
public struct BuildersRules : GameRules {
    // MARK: Properties

    static let cardsNeededInHand = 7
    static let floorsNeededToWin = 1

    /// The context these rules are applying to
    public unowned let context: BuildersBoard

    private var moveCount = 0

    // MARK: Initializers

    /// Creates a new `BuildersRules` with the given `BuildersBoard`
    public init(context: BuildersBoard) {
        self.context = context
    }

    // MARK: Methods

    /// Executes a turn.
    public mutating func executeTurn() -> EventLoopFuture<BuildersBoardState> {
        #if DEBUG
        print("\(context.activePlayer.id)'s turn")
        #endif

        moveCount += 1

        return context.state
                ~~> StartPhase.self
                ~~> CountPhase.self
                ~~> DealPhase.self
                ~~> DrawPhase.self
                ~~> BuildPhase.self
                ~~> EndPhase.self
    }

    /// Calculates whether or not this game is over, returning the winning players.
    ///
    /// - returns: An array of `BuilderPlayer` who've won, or an empty array if no one has one.
    public func getWinners() -> [BuilderPlayer] {
        return context.state.hotels.filter({ $0.value.floorsBuilt >= BuildersRules.floorsNeededToWin }).map({ $0.key })
    }

    /// Starts a game. This is called to deal cards, give money, etc, before the first player goes.
    public mutating func setupGame() {
        // Every player gets 2 workers and 5 material to start a game.
        for player in context.players {
            fillHand(ofPlayer: player)
        }
    }

    private func fillHand(ofPlayer player: BuilderPlayer) {
        for i in 0..<BuildersRules.cardsNeededInHand {
            switch i {
            case 0...1:
                context.state.cardsInHand[player]!.append(Worker.getInstance())
            case _:
                context.state.cardsInHand[player]!.append(Material.getInstance())
            }
        }
    }
}
