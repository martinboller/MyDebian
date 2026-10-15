# Note that Ghidra must have been started at least once for this to work

import pyghidra

# Start the Ghidra JVM and CPython bridge
pyghidra.start()

# Now you can import Ghidra packages for analysis
from ghidra.app.util.importer import MessageLog
from ghidra.program.model.listing import Program

print("PyGhidra initialized successfully!")