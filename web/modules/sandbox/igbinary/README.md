IgBinary Serialization Service
===

>Nombre de máquina: igbinary

[![version][version-badge]][changelog]
[![Licencia][license-badge]][license]
[![Código de conducta][conduct-badge]][conduct]
[![Donate][donate-badge]][donate-url]

---

## Información
La serialización de PHP se usa mucho en Drupal. Pero Drupal 8 introdujo
servicios de serialización que podían intercambiarse. Este módulo ofrece un
servicio de serialización basado en igbinary.

---

## Requisitos
* (Ver composer.json proporcionado).

---

## Instalación / Configuración
* Una vez instalado y activado el módulo es necesario hacer una serie de
  modificaciones en los servicios de Drupal. Consulte el archivo
  example.services.yml.

---
⌨️ con ❤️ por [Óscar Novás][mi-web] 😊

[mi-web]: https://oscarnovas.com "for developers"

[version]: v1.0.0
[version-badge]: https://img.shields.io/badge/Versión-1.0.0-blue.svg

[license]: LICENSE.md
[license-badge]: https://img.shields.io/badge/Licencia-GPLv3+-green.svg "Leer la licencia"

[conduct]: CODE_OF_CONDUCT.md
[conduct-badge]: https://img.shields.io/badge/C%C3%B3digo%20de%20Conducta-2.0-4baaaa.svg "Código de conducta"

[changelog]: CHANGELOG.md "Histórico de cambios"
[contributors]: https://github.com/oscarnovasf/vscode_config/contributors "Ver contribuyentes"

[donate-badge]: https://img.shields.io/badge/Donaci%C3%B3n-PayPal-red.svg
[donate-url]: https://paypal.me/oscarnovasf "Haz una donación"







igbinary serialization
======================

Este paquete proporciona diferentes serializadores para usar igbinary.

igbinary
--------

TODO

igbinary compressed
-------------------

TODO

php compressed
--------------

TODO

Getting started
===============

Tell Drupal to use the lock backend
-----------------------------------

See the provided example.services.yml file on how to override the serialization
services used by various other services.
