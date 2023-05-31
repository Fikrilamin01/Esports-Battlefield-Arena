import 'dart:math';

import 'package:esports_battlefield_arena/app/failures.dart';
import 'package:esports_battlefield_arena/app/router.dart';
import 'package:esports_battlefield_arena/app/router.gr.dart';
import 'package:esports_battlefield_arena/app/service_locator.dart';
import 'package:esports_battlefield_arena/models/organizer.dart';
import 'package:esports_battlefield_arena/models/player.dart';
import 'package:esports_battlefield_arena/models/tournament.dart';
import 'package:esports_battlefield_arena/models/tournament_participant.dart';
import 'package:esports_battlefield_arena/models/user.dart';
import 'package:esports_battlefield_arena/models/username.dart';
import 'package:esports_battlefield_arena/services/firebase/authentication/auth.dart';
import 'package:esports_battlefield_arena/services/firebase/database/database.dart';
import 'package:esports_battlefield_arena/services/firebase/firestore_config.dart';
import 'package:esports_battlefield_arena/services/log/log_services.dart';
import 'package:esports_battlefield_arena/services/seeding/seeding.dart';
import 'package:esports_battlefield_arena/services/viewmodel_shared_data/tournament_service.dart';
import 'package:esports_battlefield_arena/shared/app_colors.dart';
import 'package:esports_battlefield_arena/utils/enum.dart';
import 'package:esports_battlefield_arena/utils/mock_data_generator/mock_data_generator.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class OrganizedTournamentDetailViewModel extends ReactiveViewModel {
  final AppRouter _router = locator<AppRouter>();
  final Database _database = locator<Database>();
  final Auth _auth = locator<Auth>();
  final LogService _log = locator<LogService>();
  final Seeding _seedingAlgorithm = locator<Seeding>();
  final _tournamentService = locator<TournamentService>();

  // State
  bool isParticipantButtonBusy = false;
  bool isLeaderboardButtonBusy = false;

  void updateTournament(Tournament tournament) {
    _tournamentService.updateTournament(tournament);
    notifyListeners();
  }

  void navigateToEditTournament(Tournament tournament) {
    updateTournament(tournament);
    _router.push(const CreateTournamentRoute());
  }

  void viewAllParticipants(Tournament tournament) {
    isParticipantButtonBusy = true;
    notifyListeners();
    _tournamentService.getAllParticipantInformation(tournament);
    _router.push(const ParticipantInformationRoute());
    isParticipantButtonBusy = false;
    notifyListeners();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_tournamentService];

  createSeeding(Tournament tournament, context) async {
    setBusy(true);
    // await _database.update(tournament.tournamentId, {'matchList': []},
    //     FirestoreCollections.tournament);
    try {
      bool sucess = false;
      if (tournament.game == GameType.ApexLegend.name) {
        // _seedingAlgorithm.generateMatchForApex(tournament);
        sucess = await _seedingAlgorithm.seedTeamsForApex(tournament);
      } else {
        // _seedingAlgorithm.generateMatchForSingleElimination(tournament, 3);
        sucess =
            await _seedingAlgorithm.seedTeamsForSingleElimination(tournament);
        // for (int i = 0; i < tournament.matchList.length; i++) {
        //   await _database.delete(
        //       tournament.matchList[i], FirestoreCollections.valorantMatch);
        // }
      }
      if (sucess) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.error,
                      color: kcPrimaryDarkerColor,
                    ),
                    SizedBox(
                      width: 200,
                      child: Text('Sucessfully create seeding'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.error,
                      color: kcTertiaryColor,
                    ),
                    SizedBox(
                      width: 200,
                      child: Text('There is an error creating seeding'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      setBusy(false);
      return;
    } on Failure catch (e) {
      _log.info('${e.message!} \n ${e.location!}');
      setBusy(false);
      return;
    } catch (e) {
      _log.info(e.toString());
      setBusy(false);
      return;
    } finally {
      setBusy(false);
      return;
    }
  }

  Future<void> viewLeaderboard(Tournament tournament) async {
    isLeaderboardButtonBusy = true;
    notifyListeners();
    await _tournamentService.getLeaderboardResult(tournament);
    _router.push(const LeaderboardRoute());
    isLeaderboardButtonBusy = false;
    notifyListeners();
  }
}
