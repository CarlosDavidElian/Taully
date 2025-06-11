import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference _productsRef = FirebaseFirestore.instance
      .collection('products');

  Future<void> addProduct(Map<String, dynamic> productData) {
    return _productsRef.add(productData);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> productData) {
    return _productsRef.doc(id).update(productData);
  }

  Future<void> deleteProduct(String id) {
    return _productsRef.doc(id).delete();
  }

  Stream<List<Map<String, dynamic>>> getProductsByCategory(String category) {
    return _productsRef
        .where('category', isEqualTo: category)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => {
                      ...doc.data() as Map<String, dynamic>,
                      'id': doc.id,
                    },
                  )
                  .toList(),
        );
  }

  Future<List<Map<String, dynamic>>> searchProductsByName(String name) async {
    final querySnapshot =
        await _productsRef
            .where('name', isGreaterThanOrEqualTo: name)
            .where('name', isLessThan: name + 'z')
            .get();
    return querySnapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .toList();
  }
}
