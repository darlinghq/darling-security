# Additional Update Guidelines for Security

As a reminder, these are *guidelines*. The version you update to might make some of these steps obsolete, so make sure you understand what they do and why they're necessary.

## Generates Sources

```bash
darling/scripts/produce_schemas.sh
darling/scripts/cssm_generator.sh
# Read the notes in the generate_d_files.sh file before executing it.
darling/scripts/generate_d_files.sh
```

## Symbol Links

Most of the `security` folders (inside the `darling/include` folder) are set up as symbolic links (for example, the folder `security_asn1` point to `OSX/libsecurity_asn1/lib`). A consequence of this approach is that some of the files will need to be symbol-linked.

```bash
ln -s ../../../gen/cstemp/codesigning_dtrace.h --target-directory="OSX/libsecurity_codesigning/lib/"
ln -s ../../../libsecurity_smime/lib/SecAsn1Item.h --target-directory="OSX/libsecurity_smime/lib/"
ln -s ../../utilities/debugging.h --target-directory="OSX/libsecurity_utilities/lib/"
ln -s ../../utilities/simulatecrash_assert.h --target-directory="OSX/libsecurity_utilities/lib/"
ln -s ../../../gen/derived_src/security_utilities/utilities_dtrace.h --target-directory="OSX/libsecurity_utilities/lib/"
ln -s ../mig/ss_types.defs --target-directory="OSX/libsecurityd/lib/"
```