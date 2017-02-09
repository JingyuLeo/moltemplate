  # moltemplate_cleanup.sh
  # This script attempts to remove irrelevant information from LAMMPS 
  # input scripts and data files (such as extra, unneeded atom types 
  # and force field parameters).
  #
  # Unfortunately, the system.data and system.in.settings file which are
  # created by moltemplate.sh often contain a lot of irrelevant information,
  # such as definition of parameters for atom types defined in the force field
  # but not present in the current system.
  #
  # In my experience, this extra information appears to be mostly harmless.
  # (Loading this information does not seem to slow down LAMMPS significantly.)
  # 
  # However it can make visualization difficult in VMD.  (Technically, this
  # extra information can take up megabytes of space in the system.data
  # and system.in.settings files.  Later when you run LAMMPS, a O(n^2) sized
  # table is generated internally to store the pair parameters for n atom types)
  #
  # Usage: Invoke this script with no arguments, from a directory
  #        containing these files:
  #          system.data, system.in.init, system.in.settings, system.in.charges
  #        It will modify these files to remove unnecessary atoms and 
  #        parameters.  (If your files have other names, you must rename 
  #        them to match moltemplate file name conventions.)
  #
  # DO NOT USE THIS SCRIPT ON SIMULATIONS CONTAINING MANY-BODY PAIR 
  # STYLES, DREIDING HYDROGEN BONDS, OR NON-STANDARD AUXILIARY FILES.
  # (This script relies on ltemplify.py, and inherits its limitations.)

  PATH_TO_DATA_FILE="."

  pushd "$PATH_TO_DATA_FILE"

  mkdir new_lt_file_TMP
  cd new_lt_file_TMP

  # now run ltemplify.py

  ltemplify.py ../system.in.* ../system.data > system.lt

  # This creates a new .LT file named "system.lt" in the local directory.

  # The ltemplify.py script also does not copy the boundary dimensions.
  # We must do this manually.
  # If you did NOT throw away the "Data Boundary" file usually located in
  # "moltemplate_files/output_ttree/Data Boundary"
  # then you can copy that information from this file into system.lt

  PATH_TO_OUTPUT_TTREE="output_ttree"

  echo "write_once(\"Data Boundary\") {" >> system.lt
  cat "$PATH_TO_OUTPUT_TTREE/Data Boundary" >> system.lt
  echo "}" >> system.lt
  echo "" >> system.lt

  # Now, run moltemplate on this new .LT file.
  moltemplate.sh system.lt
  # This will create: "system.data" "system.in.init" "system.in.settings."

  # That's it.  The new "system.data" and system.in.* files should
  # be ready to run in LAMMPS.

  # Now copy the system.data and system.in.* files to the place where
  # you plan to run LAMMPS
  mv -f system.data system.in.* ../
  cd ../
  grep "set type" system.in.settings > system.in.charges
  # now remove these lines from system.in.settings
  sed '/set type/,+1 d' < system.in.settings > system.in.settings.tmp
  mv -f system.in.settings.tmp system.in.settings

  # Now delete all of the temporary files we generated
  rm -rf new_lt_file_TMP
  popd

