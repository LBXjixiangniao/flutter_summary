import 'package:flutter_summary/expanded/database/database.dart';
import 'package:moor/moor.dart';

part 'list_item.g.dart';

class CacheDBItems extends Table {
  IntColumn get index => integer().named('dbIndex')();
  TextColumn get content => text()();
  TextColumn get type => text()();

  @override
  Set<Column> get primaryKey => {index};
}

@UseDao(tables: [CacheDBItems])
class CacheDBItemsDao extends DatabaseAccessor<LbxDatabase> with _$CacheDBItemsDaoMixin {
  // this constructor is required so that the main database can create an instance
  // of this object.
  CacheDBItemsDao(LbxDatabase db) : super(db);

  Future<List<CacheDBItem>> selecteIndexRangeDataInOrder(
      {@required int startIndex, @required int endIndex, @required String type}) {
    assert(startIndex != null && endIndex != null && endIndex >= startIndex && type != null);
    return (select(cacheDBItems)
          ..where((filter) =>
              filter.index.isBiggerOrEqualValue(startIndex ?? 0) &
              filter.index.isSmallerOrEqualValue(endIndex ?? 0) &
              filter.type.equals(type))
          ..orderBy([(table) => OrderingTerm.asc(table.index)]))
        .get();
  }

  Future<List<CacheDBItem>> selecteDataFromIndexInOrder(
      {@required int startIndex, @required int count, @required String type}) {
    assert(startIndex != null && count != null && count >= 0 && type != null);
    return (select(cacheDBItems)
          ..orderBy([(table) => OrderingTerm.asc(table.index)])
          ..where((filter) => filter.index.isBiggerOrEqualValue(startIndex ?? 0) & filter.type.equals(type))
          ..limit(count))
        .get();
  }

  Future<int> deleteAllForType([String type]) {
    if (type != null) {
      return (delete(cacheDBItems)..where((tbl) => tbl.type.equals(type))).go();
    } else {
      return delete(cacheDBItems).go();
    }
  }

  Future<void> insertList(List<CacheDBItem> list) {
    if (list != null && list.isNotEmpty) {
      return batch((batch) {
        batch.insertAll(cacheDBItems, list);
      });
    }
    return Future.error('插入的数组为空');
  }

  static clearTable() {
    LbxDatabase().cacheDBItemsDao.deleteAllForType();
  }
}
