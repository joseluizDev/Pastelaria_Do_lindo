class PedidoIndex {
  final int index;

  PedidoIndex(this.index);

  PedidoIndex.fromJson(Map<String, dynamic> json) : index = json['index'];

  Map<String, dynamic> toJson() => {
        'index': index,
      };
}
