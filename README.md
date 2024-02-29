# Known Domain Catalog

KDC is a file format for caataloguing internet domain names. It was invented for the Telegram [Anti-NFT Spam Bot](https://t.me/Anti_NFT_Spam_Bot)'s [scam website domain list](https://github.com/Architector4/telegram-bot-stuff/blob/main/anti_nft_spam_bot/scam-website-domain-list.kdc), to catalog domain names known to be crypto/NFT scams.

Its format is inpsired by [INI](https://en.wikipedia.org/wiki/INI_file)/[properties](https://en.wikipedia.org/wiki/.properties)/[TOML](https://toml.io/) files, (DNS zones](https://en.wikipedia.org/wiki/Zone_file)), and [Hostfiles](https://en.wikipedia.org/wiki/Hosts_(file). Unlike those, this is specifically and solely for collecting a list of domain names, and nothing else.



## Basic format

At its core, this is a series of domain names in UTF-8 encoded plaintext, with one domain name per line, like this:

```kdc
example.com
wikipedia.org
en.wikipedia.org
KyLeggiero.us
toml.io
```



## Spacing

Of course, you may add blank lines to separate groups of domains.

```kdc
example.com
wikipedia.org
en.wikipedia.org

KyLeggiero.us

toml.io
```



## Context URLs

Sometimes you might want to provide a URL for context of why the domain is included in the list. Any valid URL is allowed after the domain name, separated by whitespace:

```kdc
example.com
wikipedia.org
en.wikipedia.org

KyLeggiero.us

toml.io   https://toml.io/en/v1.0.0
```



## Comments

Comments may be added to the start or end of any line. They start with a `#` and continue to the end of the line.

For comments which appear after an entry, they _must_ be preceded with _at least_ 1 space.

```kdc
# Used commonly as examples
example.com      # This only exists to be an example website
wikipedia.org    # Wikipedia is one of the most neutral sites on the Internet
en.wikipedia.org # English Wikipedia is the first and largest version of Wikipedia

# Personal site of the folks who made this format
KyLeggiero.us

# Formats similar to KDC
toml.io   https://toml.io/en/v1.0.0   # Specifically interested in v1
```

Comments can contain any printable character at all, except newlines (which end the comment).
As long as it's after the `#`, it's freeform!

```kdc
##########################
# Common Example Domains #
##########################

example.com
wikipedia.org
en.wikipedia.org



##################
# Personal Sites #
##################

KyLeggiero.us  # 👈🏽 Anarchist plural system! 🎉



##########################
# Formats similar to KDC #
##########################

toml.io  # 🫡 We respect Tom's obvious markup language, but this is still different
```


# Full Spec

You can [view the full language spec as an EBNF](./Sources/known_domain_catalog.ebnf) if that's your thing
