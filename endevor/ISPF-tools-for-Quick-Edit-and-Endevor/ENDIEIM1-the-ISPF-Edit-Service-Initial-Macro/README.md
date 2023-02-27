# ENDIEIM1

ENDIEIM1 is Quick-Edit's Edit Session Startup Command. In this folder a snippet is provided to show how it can direct Quick-Edit to bypass its normal edit session, and instead present an ISPF panel. The element content fills the fields on the panel, and the user is given the opportunity to change them. An example ISPF panel is provided and named FORM210 - the same name expected as the element type. You can choose any name for the type. GFORMS is A sample processor for a type like FORM210.

Similar constructs for ENDIEIM1 can render a support within Quick-Edit for other element types where an edit session is undesirable. For example:

 - Telon elements where a Quick-Edit session opens the Telon Design facility
 - SDF II elements where a Quick-Edit session opens IBM's Screen Definition Facility II
