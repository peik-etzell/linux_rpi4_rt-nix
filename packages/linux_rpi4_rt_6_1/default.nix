{ lib, linuxKernel, linuxPackagesFor, fetchurl, fetchFromGitHub, raspberrypifw
, ... }: rec {
  kernel = linuxKernel.kernels.linux_rpi4.override {
    argsOverride = rec {
      modDirVersion = "6.1.73-rt22";
      version = "${modDirVersion}-notag";
      src = fetchFromGitHub {
        owner = "raspberrypi";
        repo = "linux";
        rev = "bfe927647253ab3a86be16320baa1579518c6786";
        sha256 = "1k2c7kh3dkcpaxwn6b78087nbcc2l3g0gdjrmfbvsig9w3i5gppj";
      };
      kernelPatches = [{
        name = "rt";
        patch = fetchurl {
          url =
            "https://cdn.kernel.org/pub/linux/kernel/projects/rt/6.1/older/patch-6.1.73-rt22.patch.xz";
          sha256 = "1hl7y2sab21l81nl165b77jhfjhpcc1gvz64fs2yjjp4q2qih4b0";
        };
      }] ++ linuxKernel.kernels.linux_rpi4.kernelPatches;
      structuredExtraConfig = with lib.kernel;
        {
          # KVM = lib.mkForce no; # Not compatible with PREEMPT_RT. NOTE: this conflict shoulb be fixed in 5.16
          PREEMPT_RT = yes;
          EXPERT = yes; # PREEMPT_RT depends on it (in kernel/Kconfig.preempt)
          PREEMPT_VOLUNTARY = lib.mkForce no; # PREEMPT_RT deselects it.
          RT_GROUP_SCHED = lib.mkForce
            (option no); # Removed by sched-disable-rt-group-sched-on-rt.patch.
        } // linuxKernel.kernels.linux_rpi4.structuredExtraConfig;
    };
  };

  linuxPackages = linuxPackagesFor kernel;

  firmware = raspberrypifw.overrideAttrs (old: {
    version = "notag";
    src = fetchFromGitHub {
      owner = "raspberrypi";
      repo = "firmware";
      rev = "fa7d6b8f5d4f103987ffefc7202ed25c93cd3087";
      sha256 = "1n2p7dmqp3slpl7aykcrwwk4vc54in2g86bgf3dlybz5y32qi8pj";
    };
  });
}
