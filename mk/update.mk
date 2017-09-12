update-chroot update-live update-squashfs: update-%: $(BUILD)/%
	# Unmount chroot if mounted
	scripts/unmount.sh "$<.partial"

	# Remove old chroot
	sudo rm -rf "$<.partial"

	# Copy chroot
	sudo cp -a "$<" "$<.partial"

	# Make temp directory for modifications
	sudo rm -rf "$<.partial/iso"
	sudo mkdir -p "$<.partial/iso"

	# Copy chroot script
	sudo cp "scripts/chroot.sh" "$<.partial/iso/chroot.sh"

	# Mount chroot
	"scripts/mount.sh" "$<.partial"

	# Copy GPG public key for APT CDROM
	gpg --export -a "`id -un`" | sudo tee "$<.partial/iso/apt-cdrom.key"

	# Run chroot script
	sudo chroot "$<.partial" /bin/bash -e -c \
		"UPDATE=1 \
		UPGRADE=1 \
		PURGE=\"$(RM_PKGS)\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh"

	# Unmount chroot
	"scripts/unmount.sh" "$<.partial"

	# Remove temp directory for modifications
	sudo rm -rf "$<.partial/iso"

	sudo mv "$<.partial" "$<"