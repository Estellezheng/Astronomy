<?php declare(strict_types=1);

namespace Common\Form\Element;

use Laminas\Form\Element\MultiCheckbox;

class CustomVocabMultiCheckbox extends MultiCheckbox
{
    use CustomVocabTrait;
    use TraitOptionalElement;
}
