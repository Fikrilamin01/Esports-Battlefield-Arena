import 'package:esports_battlefield_arena/models/apex_match.dart';
import 'package:esports_battlefield_arena/models/user.dart';
import 'package:esports_battlefield_arena/models/apex_match_result.dart';
import 'package:esports_battlefield_arena/models/invoice.dart';
import 'package:esports_battlefield_arena/models/organizer.dart';
import 'package:esports_battlefield_arena/models/player.dart';
import 'package:esports_battlefield_arena/models/player_stats.dart';
import 'package:esports_battlefield_arena/models/team.dart';
import 'package:esports_battlefield_arena/models/tournament.dart';
import 'package:esports_battlefield_arena/models/tournament_participant.dart';
import 'package:esports_battlefield_arena/models/valorant_match.dart';
import 'package:esports_battlefield_arena/models/valorant_match_result.dart';
import 'package:esports_battlefield_arena/services/firebase/firestore_config.dart';

//Map to store the collection name in firestore
//If the collection name is changed in firestore, it will be changed here
final Map<FirestoreCollections, Map<FirestoreDeclration, String>>
    firestoreCollectionsName = {
  FirestoreCollections.users: {
    FirestoreDeclration.collectionName: 'Users',
    FirestoreDeclration.id: 'userId'
  },
  FirestoreCollections.player: {
    FirestoreDeclration.collectionName: 'Players',
    FirestoreDeclration.id: 'userId'
  },
  FirestoreCollections.organizer: {
    FirestoreDeclration.collectionName: 'Organizers',
    FirestoreDeclration.id: 'userId'
  },
  FirestoreCollections.team: {
    FirestoreDeclration.collectionName: 'Teams',
    FirestoreDeclration.id: 'teamId'
  },
  FirestoreCollections.tournament: {
    FirestoreDeclration.collectionName: 'Tournaments',
    FirestoreDeclration.id: 'tournamentId'
  },
  FirestoreCollections.tournamentParticipant: {
    FirestoreDeclration.collectionName: 'TournamentParticipants',
    FirestoreDeclration.id: 'participantId'
  },
  FirestoreCollections.valorantMatch: {
    FirestoreDeclration.collectionName: 'ValorantMatches',
    FirestoreDeclration.id: 'matchId'
  },
  FirestoreCollections.apexMatch: {
    FirestoreDeclration.collectionName: 'ApexMatches',
    FirestoreDeclration.id: 'matchId'
  },
  FirestoreCollections.apexMatchResult: {
    FirestoreDeclration.collectionName: 'ApexMatchResults',
    FirestoreDeclration.id: 'resultId'
  },
  FirestoreCollections.valorantMatchResult: {
    FirestoreDeclration.collectionName: 'ValorantMatchResults',
    FirestoreDeclration.id: 'resultId'
  },
  FirestoreCollections.playerStats: {
    FirestoreDeclration.collectionName: 'PlayerStats',
    FirestoreDeclration.id: 'playerStatsId'
  },
  FirestoreCollections.invoice: {
    FirestoreDeclration.collectionName: 'Invoices',
    FirestoreDeclration.id: 'invoiceId'
  }
};

//This function is to ensure that all the key value pairs in the data map are valid
//For example in User class, the data map should only contain the following key value pairs:
// {
//   "userId": "123",
//   "country": "country",
//   "address": "address",
//   "email": "email",
//   "name": "name",
//   "password": "password",
//   "role": "role",
// }
// If the data map contains any other key value pairs, it will throw an error
//Also
//This function will return the instance object of the class that is associated with the collection name
//For example, if the collection name is FirestoreCollections.users, it will return an instance of User class
//However the type return is dynamic, not sure whether flutter will trigger the intellisense
dynamic checkCollectionNameAndgetModelData(
    FirestoreCollections collection, Map<String, dynamic> data) {
  try {
    // dynamic modelType = getDataModelType(collection);
    // return modelType.fromJson(data);

    switch (collection) {
      case FirestoreCollections.users:
        return User.fromJson(data);
      case FirestoreCollections.player:
        return Player.fromJson(data);
      case FirestoreCollections.organizer:
        return Organizer.fromJson(data);
      case FirestoreCollections.team:
        return Team.fromJson(data);
      case FirestoreCollections.tournament:
        return Tournament.fromJson(data);
      case FirestoreCollections.tournamentParticipant:
        return TournamentParticipant.fromJson(data);
      case FirestoreCollections.valorantMatch:
        return ValorantMatch.fromJson(data);
      case FirestoreCollections.apexMatch:
        return ApexMatch.fromJson(data);
      case FirestoreCollections.apexMatchResult:
        return ApexMatchResult.fromJson(data);
      case FirestoreCollections.valorantMatchResult:
        return ValorantMatchResult.fromJson(data);
      case FirestoreCollections.playerStats:
        return PlayerStats.fromJson(data);
      case FirestoreCollections.invoice:
        return Invoice.fromJson(data);
      default:
        throw ArgumentError('Collection name is not valid');
    }
  } on Exception {
    rethrow;
  }
}

bool checkCollectionNameAndgetFieldName(
    FirestoreCollections collection, String field) {
  switch (collection) {
    case FirestoreCollections.users:
      return User().toJson().containsKey(field);
    case FirestoreCollections.player:
      return Player().toJson().containsKey(field);
    case FirestoreCollections.organizer:
      return Organizer().toJson().containsKey(field);
    case FirestoreCollections.team:
      return Team().toJson().containsKey(field);
    case FirestoreCollections.tournament:
      return Tournament().toJson().containsKey(field);
    case FirestoreCollections.tournamentParticipant:
      return TournamentParticipant().toJson().containsKey(field);
    case FirestoreCollections.valorantMatch:
      return ValorantMatch().toJson().containsKey(field);
    case FirestoreCollections.apexMatch:
      return ValorantMatch().toJson().containsKey(field);
    case FirestoreCollections.apexMatchResult:
      return ApexMatchResult().toJson().containsKey(field);
    case FirestoreCollections.valorantMatchResult:
      return ValorantMatchResult().toJson().containsKey(field);
    case FirestoreCollections.playerStats:
      return PlayerStats().toJson().containsKey(field);
    case FirestoreCollections.invoice:
      return Invoice().toJson().containsKey(field);
    default:
      throw ArgumentError('Collection name is not valid');
  }
  // dynamic modelType = getDataModelType(collection);
  // if (modelType.toJson().containsKey(field)) {
  //   return true;
  // }
  // return false;
}

dynamic getDataModelType(FirestoreCollections collection) {
  switch (collection) {
    case FirestoreCollections.users:
      return User;
    case FirestoreCollections.player:
      return Player;
    case FirestoreCollections.organizer:
      return Organizer;
    case FirestoreCollections.team:
      return Team;
    case FirestoreCollections.tournament:
      return Tournament;
    case FirestoreCollections.tournamentParticipant:
      return TournamentParticipant;
    case FirestoreCollections.valorantMatch:
      return ValorantMatch;
    case FirestoreCollections.apexMatch:
      return ValorantMatch;
    case FirestoreCollections.apexMatchResult:
      return ApexMatchResult;
    case FirestoreCollections.valorantMatchResult:
      return ValorantMatchResult;
    case FirestoreCollections.playerStats:
      return PlayerStats;
    case FirestoreCollections.invoice:
      return Invoice;
    default:
      throw ArgumentError('Collection name is not valid');
  }
}
