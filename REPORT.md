# Лабораторная работа 09. Создание артефактов и управление релизами автоматизированными средствами на примере CPack и GitHub Releases

---

## 1. Подготовка окружения и импорт исходного кода
В соответствии с логикой выполнения цикла лабораторных работ, в качестве кодовой базы был взят проект из репозитория `lab08`. Было произведено локальное копирование файлов в рабочую область `lab09` и осуществлена перенастройка удалённого репозитория:

```bash
cd ~/workspace
git clone [https://github.com/sofarun313131/lab08](https://github.com/sofarun313131/lab08) projects/lab09
cd projects/lab09
git remote remove origin
git remote add origin [https://github.com/sofarun313131/lab09](https://github.com/sofarun313131/lab09)
sed -i 's/lab08/lab09/g' README.md
```
## 2. Конфигурация модуля CPack в CMake Lists
Для того чтобы система CMake умела самостоятельно упаковывать скомпилированные бинарные файлы и необходимые заголовочные компоненты в готовые архивы, в конец файла CMakeLists.txt был добавлен конфигурационный блок встроенного макроса CPack.
Добавленные параметры:
CPACK_GENERATOR "TGZ" — директива, предписывающая генерировать сжатый архив формата .tar.gz.
CPACK_PACKAGE_VERSION "0.1.0" — установка начальной версии программного продукта для формирования имени архива.
Итоговый листинг добавленного блока:
```bush

set(CPACK_GENERATOR "TGZ")
set(CPACK_PACKAGE_VERSION "0.1.0")
include(CPack)
```
## 3. Проектирование автоматизированного CI/CD воркфлоу в GitHub Actions
Поскольку ручной вызов утилит публикации релизов на локальной машине разработчика нарушает базовые принципы методологии DevOps, весь процесс был полностью автоматизирован внутри облачной инфраструктуры GitHub.
В каталоге .github/workflows/ был разработан конфигурационный файл actions.yml. Триггером запуска конвейера было выбрано событие создания и пуша Git-тега, соответствующего маске семантического версионирования v* (например, v0.1.0).
Для выполнения требований безопасности конвейеру были явно выданы права на запись в репозиторий (contents: write), что позволяет виртуальной машине оперировать релизами без генерации ручных персональных токенов (Personal Access Tokens), которые использовались в старых утилитах вроде github-release.
Полное содержимое разработанного .github/workflows/actions.yml:
```bush
name: Release Artifacts CI

on:
  push:
    tags:
      - 'v*' # Сценарий активируется только при отправке тегов версий

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write # Разрешение на создание релизов внутри GitHub

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Configure CMake
      run: cmake -H. -B_build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=_install

    - name: Build Project
      run: cmake --build _build

    - name: Pack Artifacts via CPack
      # Вызов встроенного упаковщика для генерации целевого архива
      run: |
        cd _build
        cpack -G TGZ

    - name: Generate Artifact Checksum (Security & Integrity Verification)
      # Генерация контрольной суммы хэша SHA-256 для проверки целостности артефакта
      run: |
        cd _build
        sha256sum *.tar.gz > checksums.txt

    - name: Create GitHub Release and Upload Artifacts
      # Автоматическое формирование релиза и прикрепление дистрибутива с хэш-файлом
      uses: softprops/action-gh-release@v2
      with:
        tag_name: ${{ github.ref_name }}
        name: Release ${{ github.ref_name }}
        draft: false
        prerelease: false
        files: |
          _build/*.tar.gz
          _build/checksums.txt
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
2.4. Публикация и валидация результатов сборки
После завершения проектирования, обновлённые конфигурационные файлы были отправлены в основную ветку репозитория. Для инициации процесса релиза, коммиту был присвоен тег версии v0.1.0, который затем был отправлен на удалённый сервер:
```Bashgit add CMakeLists.txt README.md .github/workflows/actions.yml
git commit -m "feat: implement cpack configuration and modern actions workflow"
git push origin main

git tag v0.1.0
git push origin v0.1.0
```
Виртуальный сервер GitHub Actions успешно перехватил триггер тега, развернул окружение Ubuntu, скомпилировал проект, сформировал архив с помощью утилиты cpack и рассчитал контрольную сумму sha256sum для верификации целостности пакета.
В результате выполнения шага публикации, в репозитории автоматически сформировался официальный Release v0.1.0, содержащий следующие прикреплённые бинарные артефакты:
print-0.1.0-Linux.tar.gz — скомпилированный и упакованный дистрибутив программы.
checksums.txt — верификационный файл, содержащий уникальный хэш архива для защиты от подмены данных при скачивании (альтернатива устаревшему ручному локальному шифрованию через GPG).EOF
