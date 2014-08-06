#!/usr/bin/perl
use perl5i::2;
use lib 'lib';
use HITS::SIFTest;
use Data::Dumper;

my $xml = q{<MyObjOne RefId="ABC-123">Notes Here</MyObjOne>};
say HITS::SIFTest::post('scott1', 'MyObjOnes/MyObjOne', $xml);

$xml = q{<MyObjOne RefId="ABC-111">Another</MyObjOne>};
say HITS::SIFTest::post('scott1', 'MyObjOnes/MyObjOne', $xml);

$xml = q{<MyObjOne RefId="ABC-222">Again</MyObjOne>};
say HITS::SIFTest::post('scott1', 'MyObjOnes/MyObjOne', $xml);

$xml = q{<AnotherObjs RefId="ABC-222">Again</AnotherObjs>};
say HITS::SIFTest::post('scott1', 'AnotherObjs/AnotherObj', $xml);

say "OUT ONE\n" . HITS::SIFTest::get('scott1', 'MyObjOnes/ABC-123');

say "OUT MANY\n" . HITS::SIFTest::get('scott1', 'MyObjOnes');

#say Dumper(HITS::SIFTest::stats('scott1'));

$xml = q{<DanOne RefId="XXX1"><title>Test</title><brokenxml></DanOne>};
say HITS::SIFTest::post('scott1', 'DanOnes/DanOne', $xml);

say HITS::SIFTest::get('scott1', 'DanOnes');

HITS::SIFTest::post('scott1', 'StudentPersonals/StudentPersonal', q{<StudentPersonal RefId="818EDEE4F13211E3803A8FE12A7E0E35">
  <PersonInfo>     
    <Name Type="LGL">       
        <FamilyName>UPDATED TheFamilyName SL</FamilyName>
     </Name> 
   </PersonInfo>
</StudentPersonal> 
});;

HITS::SIFTest::process('scott1', 'StudentPersonals/818EDEE4F13211E3803A8FE12A7E0E35');

# Bad object type
HITS::SIFTest::post('scott1', 'StudentPersonals/StudentPersonal', q{<XStudentPersonal RefId="918EDEE4F13211E3803A8FE12A7E0E35">
  <PersonInfo>     
    <Name Type="LGL">       
        <FamilyName>UPDATED TheFamilyName SL</FamilyName>
     </Name> 
   </PersonInfo>
</XStudentPersonal> 
});;
HITS::SIFTest::process('scott1', 'StudentPersonals/918EDEE4F13211E3803A8FE12A7E0E35');

