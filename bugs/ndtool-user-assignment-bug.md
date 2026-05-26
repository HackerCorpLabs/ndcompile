# Bug Report: --put always assigns files to SYSTEM (user_index 0)

## Summary

`ndtool --put` ignores the `--dest USER` flag and the `USER/NAME:TYPE` path format. All newly created files get `user_index = 0` (SYSTEM) regardless of the specified destination user.

## Environment

- ndtool 1.0.0 (built May 26 2026 07:36:59)
- Linux (WSL2)

## Steps to Reproduce

```bash
# Start with a clean disk image
cp SMD0.IMG.bak SMD0.IMG

# Create the BUILD user
ndtool --useradd BUILD 500 SMD0.IMG

# Verify BUILD user exists
ndtool -u SMD0.IMG | grep BUILD
# Output: [ 15]  BUILD  Reserved: 500  Used: 0  Free: 500

# Method 1: Using --dest flag
ndtool -p --put testfile.txt --dest BUILD TESTFILE:TXT SMD0.IMG

# Method 2: Using USER/NAME:TYPE path format
ndtool -p --put testfile.txt BUILD/TESTFILE:TXT SMD0.IMG

# Check actual owner
ndtool --stat TESTFILE:TXT SMD0.IMG | grep User
```

## Expected Result

```
UserIndexOfReservingUser  : 15
UserName                  : BUILD
```

## Actual Result

```
UserIndexOfReservingUser  : 0
UserName                  : SYSTEM
```

## Additional Observations

1. `ndtool -t -u BUILD` reports the file under BUILD, but SINTRAN sees it under SYSTEM. This suggests ndtool tracks ownership in memory differently from what gets written to the object entry on disk.

2. `ndtool --rm` also appears non-functional. It outputs the filesystem summary but does not delete the file:
```bash
ndtool -f --rm TESTFILE:TXT SMD0.IMG
# Output: filesystem info only, no "Deleted" message
ndtool -t SMD0.IMG | grep TESTFILE
# File still exists
```

## Root Cause Analysis

In `ndfs-c/src/object_entry.c`, the `ndfs_oe_to_bytes()` function writes `entry->user_index` to byte offset 34 of the object entry. However, the value written may not match the intended user.

In `ndfs-c/src/filesystem.c` line 677:
```c
entry.user_index = fs->users[user_slot].user_index;
```

The `user_slot` (internal array position) and `user_index` (byte 37 of user entry on disk) may be diverging. The `ndfs_add_user()` function sets `user.user_index = (uint8_t)slot` (line 1373), but when loading existing users from disk via `ndfs_ue_from_bytes()`, the `user_index` comes from byte 37 of the user entry. If the internal slot assignment during loading does not match the on-disk user_index, files get assigned to the wrong user.

Also: `ndfs_oe_to_bytes()` does not write `access_bits` at all (bytes 22-31 are zeroed), causing SINTRAN to see files with no permissions. Existing files on disk have permissions set in this range, but `ndfs_oe_from_bytes()` never reads them either.

## Secondary Bug: --rm not deleting files

The `--rm` command outputs filesystem statistics but does not actually delete the specified file. Both `ndtool --rm NAME:TYPE IMAGE` and `ndtool -f --rm NAME:TYPE IMAGE` fail silently.

## Impact

Cannot use ndtool to build a development workflow where files are placed in specific user directories. All files end up under SYSTEM regardless of destination.
