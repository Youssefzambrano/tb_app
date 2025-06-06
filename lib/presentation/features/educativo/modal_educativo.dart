import 'package:flutter/material.dart';

// ------------ 1. Mostrar la imagen (o imágenes) en pantalla completa con zoom y scroll -------------
void mostrarImagenGrande(
  BuildContext context,
  List<String> imagenes,
  int indiceInicial,
) {
  showDialog(
    context: context,
    builder:
        (context) => _ImagenGrandeDialog(
          imagenes: imagenes,
          indiceInicial: indiceInicial,
        ),
  );
}

// Widget personalizado para el carrusel de imágenes con zoom y scroll
class _ImagenGrandeDialog extends StatefulWidget {
  final List<String> imagenes;
  final int indiceInicial;

  const _ImagenGrandeDialog({
    required this.imagenes,
    required this.indiceInicial,
  });

  @override
  State<_ImagenGrandeDialog> createState() => _ImagenGrandeDialogState();
}

class _ImagenGrandeDialogState extends State<_ImagenGrandeDialog> {
  late int _paginaActual;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _paginaActual = widget.indiceInicial;
    _controller = PageController(initialPage: _paginaActual);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.imagenes.length,
            onPageChanged: (i) => setState(() => _paginaActual = i),
            itemBuilder: (context, idx) {
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.asset(
                      widget.imagenes[idx],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
          // Indicador de páginas (abajo centrado)
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_paginaActual + 1} / ${widget.imagenes.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------ 2. Función para texto con negrilla, saltos de línea y numeración -------------
RichText parsearTextoConEstilos(String texto) {
  final List<TextSpan> spans = [];
  final List<String> lineas = texto.split('\n');
  for (var linea in lineas) {
    String contenido = linea.trim();
    if (contenido.isEmpty) {
      spans.add(const TextSpan(text: '\n'));
      continue;
    }
    // Busca negrillas
    final regex = RegExp(r'\*\*(.+?)\*\*');
    final matches = regex.allMatches(contenido);

    int ultimoIndex = 0;
    List<TextSpan> partes = [];
    for (final match in matches) {
      if (match.start > ultimoIndex) {
        partes.add(
          TextSpan(
            text: contenido.substring(ultimoIndex, match.start),
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        );
      }
      partes.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      ultimoIndex = match.end;
    }
    if (ultimoIndex < contenido.length) {
      partes.add(
        TextSpan(
          text: contenido.substring(ultimoIndex),
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
      );
    }
    spans.addAll(partes);
    if (linea != lineas.last) {
      spans.add(const TextSpan(text: '\n'));
    }
  }
  return RichText(
    text: TextSpan(
      style: const TextStyle(
        fontSize: 20, // Letra más grande
        color: Colors.black,
        fontFamily: 'Manrope',
      ),
      children: spans,
    ),
    textAlign: TextAlign.left,
  );
}

// ------------ 3. Modal educativo principal (para cada bloque) -------------
void mostrarModalBloqueEducativo(
  BuildContext context,
  List<dynamic> bloque,
  String tituloBloque,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.98,
        builder:
            (_, controller) => Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      tituloBloque,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        fontFamily: 'Manrope',
                        color: Color(0xFF67BF63),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      itemCount: bloque.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final tema = bloque[i];
                        // Permitir imagenes como String o como Lista
                        final imagenesRaw = tema['imagenes'];
                        List<dynamic> imagenes = [];
                        if (imagenesRaw != null) {
                          if (imagenesRaw is String) {
                            imagenes = [imagenesRaw];
                          } else if (imagenesRaw is List) {
                            imagenes = imagenesRaw;
                          }
                        }
                        final String? imagen = tema['imagen'];

                        return _CardTemaEducativo(
                          titulo: tema['titulo'] ?? '',
                          contenido: tema['contenido'] ?? '',
                          imagenes: imagenes,
                          imagen: imagen,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      );
    },
  );
}

// ------------ 4. CardTemaEducativo: muestra cada tema con imágenes (toca para ampliar) -------------
class _CardTemaEducativo extends StatefulWidget {
  final String titulo;
  final String contenido;
  final List<dynamic> imagenes;
  final String? imagen;

  const _CardTemaEducativo({
    required this.titulo,
    required this.contenido,
    required this.imagenes,
    required this.imagen,
  });

  @override
  State<_CardTemaEducativo> createState() => _CardTemaEducativoState();
}

class _CardTemaEducativoState extends State<_CardTemaEducativo> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final bool hasMany = widget.imagenes.isNotEmpty;
    final int totalPages = hasMany ? widget.imagenes.length : 1;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Manrope',
                color: Color(0xFF67BF63),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (hasMany)
              Column(
                children: [
                  SizedBox(
                    height: 220,
                    child: PageView.builder(
                      itemCount: widget.imagenes.length,
                      controller: PageController(
                        viewportFraction: 0.93,
                        initialPage: _currentPage,
                      ),
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder:
                          (context, idx) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap:
                                  () => mostrarImagenGrande(
                                    context,
                                    widget.imagenes.cast<String>(),
                                    idx,
                                  ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  widget.imagenes[idx],
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: 220,
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Indicador numérico "actual / total"
                  Text(
                    '${_currentPage + 1} / $totalPages',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF67BF63),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else if (widget.imagen != null && widget.imagen!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap:
                      () => mostrarImagenGrande(context, [widget.imagen!], 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      widget.imagen!,
                      fit: BoxFit.contain,
                      height: 220,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            parsearTextoConEstilos(widget.contenido),
          ],
        ),
      ),
    );
  }
}
