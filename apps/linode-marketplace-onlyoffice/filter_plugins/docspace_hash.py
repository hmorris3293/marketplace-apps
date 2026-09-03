"""Custom Jinja filters for the ONLYOFFICE DocSpace marketplace app."""
import hashlib


def pbkdf2_hex(password, salt, iterations=100000, size=256):
    """Return the PBKDF2-HMAC-SHA256 hex digest DocSpace expects for a password.

    ``salt``, ``iterations`` and ``size`` come from the portal's
    ``/api/2.0/settings?withPassword=true`` response. ``size`` is the derived
    key length in bits (DocSpace default 256, i.e. a 32-byte / 64-hex digest).
    """
    derived = hashlib.pbkdf2_hmac(
        "sha256",
        str(password).encode("utf-8"),
        str(salt).encode("utf-8"),
        int(iterations),
        int(size) // 8,
    )
    return derived.hex()


class FilterModule(object):
    """Expose the DocSpace password-hash filter to Ansible."""

    def filters(self):
        return {"pbkdf2_hex": pbkdf2_hex}
